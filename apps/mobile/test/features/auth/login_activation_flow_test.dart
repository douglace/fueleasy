import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/providers.dart';
import 'package:fusy_mobile/core/widgets/info_banner.dart';
import 'package:fusy_mobile/main.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Flux « compte non activé » : le login au PIN temporaire renvoie un 422
/// avec reason `account_not_activated` → bandeau info + action directe vers
/// l'activation pré-remplie (code org + identifiant conservés).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => initializeDateFormatting('fr_FR'));

  Future<ProviderScope> app() async {
    FlutterSecureStorage.setMockInitialValues({});
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api/v1/mobile/'));
    final adapter = DioAdapter(dio: dio);
    adapter.onPost(
      'auth/login',
      (server) => server.reply(422, {
        'message':
            'Compte non activé. Utilisez « Activer mon compte » avec votre PIN temporaire.',
        'reason': 'account_not_activated',
      }),
      data: Matchers.any,
    );
    return ProviderScope(
      overrides: [dioProvider.overrideWithValue(dio)],
      child: const FusyApp(),
    );
  }

  testWidgets(
    'un login sur compte non activé propose l\'activation pré-remplie',
    (tester) async {
      await tester.pumpWidget(await app());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '8AFGMF');
      await tester.enterText(find.byType(TextField).at(1), 'PEDSDS');
      await tester.enterText(find.byType(TextField).at(2), '1234');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pumpAndSettle();

      // Bandeau info avec action, pas une erreur générique.
      expect(find.byType(InlineBanner), findsOneWidget);
      expect(find.textContaining('Compte non activé'), findsOneWidget);
      final action = find.widgetWithText(TextButton, 'Activer mon compte');
      expect(action, findsOneWidget);

      await tester.tap(action);
      await tester.pumpAndSettle();

      // Écran d'activation pré-rempli avec le code org et l'identifiant.
      expect(find.text('Activation du compte'), findsOneWidget);
      expect(find.text('8AFGMF'), findsOneWidget);
      expect(find.text('PEDSDS'), findsOneWidget);
    },
  );
}
