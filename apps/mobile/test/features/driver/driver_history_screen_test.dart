import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/features/driver/driver_providers.dart';
import 'package:fusy_mobile/features/driver/screens/driver_history_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  Payment payment({
    int id = 1,
    String status = 'paid',
    String shortCode = 'K9M2P5',
  }) {
    return Payment.fromJson({
      'id': id,
      'reference': 'FUSY-ABC12XYZ',
      'short_code': shortCode,
      'status': status,
      'via': 'dynamic',
      'fuel_type': 'gasoil',
      'amount': 15000,
      'failure_reason': null,
      'station_organization_id': 10,
      'pump_id': 2,
      'expires_at': '2026-07-01T12:10:00Z',
      'confirmed_at': status == 'paid' ? '2026-07-01T12:05:30Z' : null,
      'created_at': '2026-07-01T12:05:00Z',
    });
  }

  testWidgets('shows the empty state when there is no history', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          driverHistoryProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: DriverHistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucune transaction pour le moment'), findsOneWidget);
  });

  testWidgets('renders a grouped list with status badges for real payments', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          driverHistoryProvider.overrideWith(
            (ref) async => [
              payment(id: 1, status: 'paid'),
              payment(id: 2, status: 'expired', shortCode: 'ZZZZZZ'),
            ],
          ),
        ],
        child: const MaterialApp(home: DriverHistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Payée'), findsOneWidget);
    expect(find.text('Expirée'), findsOneWidget);
    final nbsp = String.fromCharCode(0xA0);
    expect(find.text('15${nbsp}000${nbsp}FCFA'), findsNWidgets(2));
  });

  testWidgets('tapping a row opens the transaction detail screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          driverHistoryProvider.overrideWith((ref) async => [payment()]),
        ],
        child: const MaterialApp(home: DriverHistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Payée'));
    await tester.pumpAndSettle();

    expect(find.text('Détail transaction'), findsOneWidget);
    expect(find.text('K9M2P5'), findsOneWidget);
  });
}
