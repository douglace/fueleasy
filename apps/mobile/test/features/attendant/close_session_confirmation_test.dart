import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/providers.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/features/attendant/attendant_providers.dart';
import 'package:fusy_mobile/features/attendant/screens/attendant_profile_screen.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// La fermeture de session de travail exige une confirmation explicite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  (Widget, DioAdapter, List<String>) app() {
    FlutterSecureStorage.setMockInitialValues({});
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api/v1/mobile/'));
    final adapter = DioAdapter(dio: dio);
    // Le callback d'onPost s'exécute à l'enregistrement (pas à la requête) :
    // on trace les appels réellement émis via un intercepteur.
    final requestedPaths = <String>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedPaths.add(options.path);
          handler.next(options);
        },
      ),
    );
    final widget = ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(dio),
        currentSessionProvider.overrideWith(
          (ref) async => const WorkSessionQr(
            workSessionId: 42,
            pumpId: 2,
            qr: 'signed',
            expiresIn: 60,
          ),
        ),
        attendantTodayPaymentsProvider.overrideWith(
          (ref) async =>
              const TodayPayments(payments: [], appliedScope: 'pump'),
        ),
      ],
      child: const MaterialApp(home: AttendantProfileScreen()),
    );
    return (widget, adapter, requestedPaths);
  }

  testWidgets('annuler la confirmation ne ferme pas la session', (
    tester,
  ) async {
    final (widget, adapter, requestedPaths) = app();
    adapter.onPost(
      'work-sessions/42/close',
      (server) => server.reply(200, {'status': 'closed'}),
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fermer la session'));
    await tester.pumpAndSettle();

    expect(find.text('Fermer la session ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(requestedPaths, isEmpty);
    expect(find.text('Fermer la session ?'), findsNothing);
  });

  testWidgets('confirmer ferme la session via l\'API', (tester) async {
    final (widget, adapter, requestedPaths) = app();
    adapter.onPost(
      'work-sessions/42/close',
      (server) => server.reply(200, {'status': 'closed'}),
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fermer la session'));
    await tester.pumpAndSettle();

    // Le bouton de confirmation du dialogue porte le même libellé.
    await tester.tap(find.text('Fermer la session').last);
    await tester.pumpAndSettle();

    expect(requestedPaths, contains('work-sessions/42/close'));
  });
}
