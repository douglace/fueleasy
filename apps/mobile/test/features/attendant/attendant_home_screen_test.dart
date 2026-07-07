import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/features/attendant/attendant_providers.dart';
import 'package:fusy_mobile/features/attendant/screens/attendant_home_screen.dart';

void main() {
  Payment payment({String? ackedAt}) => Payment.fromJson({
    'id': 1,
    'reference': 'FUSY-X',
    'short_code': 'K9M2P5',
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

  testWidgets('prompts to open a session and shows the empty payments state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentSessionProvider.overrideWith((ref) async => null),
          attendantPumpsProvider.overrideWith((ref) async => const []),
          attendantTodayPaymentsProvider.overrideWith(
            (ref) async =>
                const TodayPayments(payments: [], appliedScope: 'station'),
          ),
        ],
        child: const MaterialApp(home: AttendantHomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucune session ouverte'), findsOneWidget);
    expect(find.text('Ouvrir une session'), findsOneWidget);
    expect(
      find.text('Aucun paiement aujourd\'hui dans cette station.'),
      findsOneWidget,
    );
  });

  testWidgets('lists today\'s payments with À accuser / Accusé badges', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentSessionProvider.overrideWith((ref) async => null),
          attendantPumpsProvider.overrideWith((ref) async => const []),
          attendantTodayPaymentsProvider.overrideWith(
            (ref) async => TodayPayments(
              payments: [
                payment(),
                payment(ackedAt: '2026-07-01T12:06:00Z'),
              ],
              appliedScope: 'pump',
              pumpId: 2,
            ),
          ),
        ],
        child: const MaterialApp(home: AttendantHomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('À accuser'), findsOneWidget);
    expect(find.text('Accusé'), findsOneWidget);
    expect(find.text('K9M2P5'), findsNWidgets(2));
  });
}
