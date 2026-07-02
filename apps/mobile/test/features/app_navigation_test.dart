import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/providers.dart';
import 'package:fusy_mobile/main.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Test d'intégration léger : traverse le vrai routeur (splash → login →
/// aiguillage par rôle) avec un Dio mocké, sans appareil.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => initializeDateFormatting('fr_FR'));

  Map<String, dynamic> user(String role) => {
    'id': 1,
    'name': role == 'driver' ? 'Boris Mballa' : 'Eric Pompiste',
    'role': role,
    'organization_id': 9,
  };

  Future<ProviderScope> app(String role) async {
    FlutterSecureStorage.setMockInitialValues({});
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api/v1/mobile/'));
    final adapter = DioAdapter(dio: dio);
    adapter.onPost(
      'auth/login',
      (server) => server.reply(200, {'token': 'tok', 'user': user(role)}),
      data: Matchers.any,
    );
    adapter.onGet('me', (server) => server.reply(200, user(role)));
    return ProviderScope(
      overrides: [dioProvider.overrideWithValue(dio)],
      child: const FusyApp(),
    );
  }

  Future<void> login(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'SCEFEA');
    await tester.enterText(find.byType(TextField).at(1), '+237600000000');
    await tester.enterText(find.byType(TextField).at(2), '1234');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();
  }

  testWidgets('a driver login lands on the driver shell (Accueil)', (
    tester,
  ) async {
    await tester.pumpWidget(await app('driver'));
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    await login(tester);

    expect(find.text('Boris Mballa'), findsWidgets);
    expect(find.text('Scanner une station'), findsOneWidget);
  });

  testWidgets('a pompiste login lands on the attendant shell (Paiements)', (
    tester,
  ) async {
    await tester.pumpWidget(await app('pompiste'));
    await tester.pumpAndSettle();

    await login(tester);

    // "Paiements" apparaît à la fois en titre d'AppBar et en libellé de nav.
    expect(find.widgetWithText(AppBar, 'Paiements'), findsOneWidget);
    expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    expect(find.text('Eric Pompiste'), findsNothing); // pas d'écran chauffeur
  });
}
