import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/domain/enums.dart';
import 'package:fusy_mobile/features/driver/models/payment_draft.dart';
import 'package:fusy_mobile/features/driver/screens/amount_entry_screen.dart';

void main() {
  final draft = PaymentDraft(
    qr: 'QR-TOKEN',
    station: const StationRef(id: 10, name: 'Tradex Bonamoussadi'),
    pump: const PumpRef(
      id: 2,
      label: 'Pompe 1',
      availableFuels: [FuelType.gasoil, FuelType.superFuel],
    ),
  );

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: AmountEntryScreen(draft: draft)),
      ),
    );
  }

  FilledButton continueButton(WidgetTester tester) => tester
      .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continuer'));

  testWidgets('shows the locked station name and both available fuels', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('Tradex Bonamoussadi'), findsOneWidget);
    expect(find.text('Gasoil'), findsOneWidget);
    expect(find.text('Super'), findsOneWidget);
  });

  testWidgets('Continuer is disabled until amount and fuel are both set', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(continueButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '15000');
    await tester.pump();
    expect(continueButton(tester).onPressed, isNull);

    await tester.tap(find.text('Super'));
    await tester.pump();
    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('tapping Continuer navigates to the Récapitulatif screen', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextField).first, '15000');
    await tester.pump();
    await tester.tap(find.text('Super'));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Continuer'));
    await tester.pumpAndSettle();

    final nbsp = String.fromCharCode(0xA0);
    expect(find.text('Récapitulatif'), findsOneWidget);
    expect(find.text('15${nbsp}000${nbsp}FCFA'), findsWidgets);
  });
}
