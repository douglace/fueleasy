import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/providers.dart';
import 'package:fusy_mobile/features/driver/screens/amount_entry_screen.dart';
import 'package:fusy_mobile/features/driver/screens/pump_code_entry_screen.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Fallback de saisie manuelle du code pompe (scan QR impossible).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  (Widget, DioAdapter) app() {
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api/v1/mobile/'));
    final adapter = DioAdapter(dio: dio);
    final widget = ProviderScope(
      overrides: [dioProvider.overrideWithValue(dio)],
      child: const MaterialApp(home: PumpCodeEntryScreen()),
    );
    return (widget, adapter);
  }

  testWidgets('la saisie est forcée en majuscules et limitée à 6 caractères', (
    tester,
  ) async {
    final (widget, _) = app();
    await tester.pumpWidget(widget);

    await tester.enterText(find.byType(TextField), 'k7m2xq99');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'K7M2XQ');
  });

  testWidgets('le bouton Continuer reste inactif avant 6 caractères', (
    tester,
  ) async {
    final (widget, _) = app();
    await tester.pumpWidget(widget);

    await tester.enterText(find.byType(TextField), 'K7M');
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('un code valide résout la pompe et ouvre la saisie du montant', (
    tester,
  ) async {
    final (widget, adapter) = app();
    adapter.onPost(
      'scan',
      (server) => server.reply(200, {
        'via': 'code',
        'station': {'id': 10, 'name': 'Station Centre-Ville'},
        'pump': {
          'id': 2,
          'label': 'Pompe 1',
          'available_fuels': ['gasoil', 'super'],
        },
        'pompiste_id': null,
      }),
      data: {'code': 'K7M2XQ'},
    );
    await tester.pumpWidget(widget);

    await tester.enterText(find.byType(TextField), 'K7M2XQ');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(find.byType(AmountEntryScreen), findsOneWidget);
    expect(find.textContaining('Station Centre-Ville'), findsWidgets);
  });

  testWidgets('un code inconnu affiche le message d\'erreur du serveur', (
    tester,
  ) async {
    final (widget, adapter) = app();
    adapter.onPost(
      'scan',
      (server) => server.reply(422, {
        'message': 'Code pompe inconnu.',
        'reason': 'pump_code_unknown',
      }),
      data: {'code': 'ZZZZZZ'},
    );
    await tester.pumpWidget(widget);

    await tester.enterText(find.byType(TextField), 'ZZZZZZ');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(find.byType(PumpCodeEntryScreen), findsOneWidget);
    expect(find.text('Code pompe inconnu.'), findsOneWidget);
  });
}
