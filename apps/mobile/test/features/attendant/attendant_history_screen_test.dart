import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/features/attendant/attendant_providers.dart';
import 'package:fusy_mobile/features/attendant/screens/attendant_history_screen.dart';

void main() {
  Payment payment({required String shortCode, String? ackedAt}) =>
      Payment.fromJson({
        'id': shortCode.hashCode,
        'reference': 'FUSY-$shortCode',
        'short_code': shortCode,
        'status': 'paid',
        'via': 'dynamic',
        'fuel_type': 'gasoil',
        'amount': 15000,
        'failure_reason': null,
        'station_organization_id': 10,
        'pump_id': 2,
        'expires_at': '2026-07-01T12:10:00Z',
        'confirmed_at': '2026-07-01T12:05:30Z',
        'created_at': '2026-07-01T12:05:00Z',
        'alert_acknowledged_at': ackedAt,
      });

  testWidgets('shows the total and filters by acknowledgement state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          attendantTodayPaymentsProvider.overrideWith(
            (ref) async => TodayPayments(
              payments: [
                payment(shortCode: 'AAAAAA'),
                payment(shortCode: 'BBBBBB', ackedAt: '2026-07-01T12:06:00Z'),
              ],
              appliedScope: 'pump',
              pumpId: 2,
            ),
          ),
        ],
        child: const MaterialApp(home: AttendantHistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final nbsp = String.fromCharCode(0xA0);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('30${nbsp}000${nbsp}FCFA'), findsOneWidget);
    expect(find.text('AAAAAA'), findsOneWidget);
    expect(find.text('BBBBBB'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'À accuser'));
    await tester.pumpAndSettle();

    expect(find.text('AAAAAA'), findsOneWidget);
    expect(find.text('BBBBBB'), findsNothing);
  });
}
