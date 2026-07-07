import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/domain/entities.dart';
import 'package:fusy_mobile/features/attendant/attendant_providers.dart';
import 'package:fusy_mobile/features/attendant/screens/attendant_history_screen.dart';

/// Toggle « Ma pompe / Toute la station » de l'historique pompiste.
void main() {
  Widget app({required TodayPayments today}) => ProviderScope(
    overrides: [
      attendantTodayPaymentsProvider.overrideWith((ref) async => today),
    ],
    child: const MaterialApp(home: AttendantHistoryScreen()),
  );

  testWidgets('affiche le toggle avec « Ma pompe » sélectionné par défaut', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        today: const TodayPayments(
          payments: [],
          appliedScope: 'pump',
          pumpId: 2,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ma pompe'), findsOneWidget);
    expect(find.text('Toute la station'), findsOneWidget);

    final segmented = tester.widget<SegmentedButton<HistoryScope>>(
      find.byType(SegmentedButton<HistoryScope>),
    );
    expect(segmented.selected, {HistoryScope.pump});
  });

  testWidgets('basculer sur « Toute la station » change le scope demandé', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        today: const TodayPayments(
          payments: [],
          appliedScope: 'pump',
          pumpId: 2,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Toute la station'));
    await tester.pumpAndSettle();

    final segmented = tester.widget<SegmentedButton<HistoryScope>>(
      find.byType(SegmentedButton<HistoryScope>),
    );
    expect(segmented.selected, {HistoryScope.station});
  });

  testWidgets(
    'mentionne la vue station quand le serveur a basculé faute de session',
    (tester) async {
      await tester.pumpWidget(
        app(
          today: const TodayPayments(payments: [], appliedScope: 'station'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Vue station — aucune session ouverte sur une pompe.'),
        findsOneWidget,
      );
    },
  );
}
