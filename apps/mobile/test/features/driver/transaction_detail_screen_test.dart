import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/features/driver/screens/transaction_detail_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  Payment paymentWithStatus(String status) => Payment.fromJson({
    'id': 1,
    'reference': 'FUSY-ABC12XYZ',
    'short_code': 'K9M2P5',
    'status': status,
    'via': 'dynamic',
    'fuel_type': 'super',
    'amount': 15000,
    'failure_reason': null,
    'station_organization_id': 10,
    'pump_id': 2,
    'expires_at': '2026-07-01T12:10:00Z',
    'confirmed_at': status == 'paid' ? '2026-07-01T12:05:30Z' : null,
    'created_at': '2026-07-01T12:05:00Z',
  });

  testWidgets('offers the receipt for a paid transaction', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TransactionDetailScreen(payment: paymentWithStatus('paid')),
        ),
      ),
    );

    expect(find.text('Voir le reçu'), findsOneWidget);
    expect(find.text('Ce document n\'est pas un reçu final.'), findsNothing);
  });

  testWidgets('warns that the document is not a final receipt otherwise', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TransactionDetailScreen(payment: paymentWithStatus('expired')),
        ),
      ),
    );

    expect(find.text('Voir le reçu'), findsNothing);
    expect(find.text('Ce document n\'est pas un reçu final.'), findsOneWidget);
  });
}
