import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/widgets/amount_display.dart';
import 'package:fusy_mobile/core/widgets/app_buttons.dart';
import 'package:fusy_mobile/core/widgets/app_text_field.dart';
import 'package:fusy_mobile/core/widgets/empty_state.dart';
import 'package:fusy_mobile/core/widgets/error_state.dart';
import 'package:fusy_mobile/core/widgets/info_banner.dart';
import 'package:fusy_mobile/core/widgets/skeleton.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('InlineBanner', () {
    testWidgets('affiche le message et déclenche l\'action', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          InlineBanner(
            message: 'Compte non activé.',
            tone: BannerTone.info,
            actionLabel: 'Activer mon compte',
            onAction: () => tapped = true,
          ),
        ),
      );
      expect(find.text('Compte non activé.'), findsOneWidget);
      await tester.tap(find.text('Activer mon compte'));
      expect(tapped, isTrue);
    });

    testWidgets('InlineErrorBanner reste compatible', (tester) async {
      await tester.pumpWidget(
        _wrap(const InlineErrorBanner(message: 'Identifiants invalides.')),
      );
      expect(find.text('Identifiants invalides.'), findsOneWidget);
      expect(find.byType(InlineBanner), findsOneWidget);
    });
  });

  group('EmptyState / ErrorState', () {
    testWidgets('EmptyState affiche titre, message et CTA', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'Aucune transaction',
            message: 'Vos paiements apparaîtront ici.',
            actionLabel: 'Actualiser',
            onAction: () => tapped = true,
          ),
        ),
      );
      expect(find.text('Aucune transaction'), findsOneWidget);
      expect(find.text('Vos paiements apparaîtront ici.'), findsOneWidget);
      await tester.tap(find.text('Actualiser'));
      expect(tapped, isTrue);
    });

    testWidgets('ErrorState propose Réessayer', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(
          ErrorState(
            message: 'Connexion instable.',
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.tap(find.text('Réessayer'));
      expect(retried, isTrue);
    });
  });

  group('Skeleton', () {
    testWidgets('SkeletonList rend le nombre de cartes demandé', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SkeletonList(count: 4)));
      await tester.pump();
      expect(find.byType(SkeletonCard), findsNWidgets(4));
      // L'animation tourne : on avance sans erreur puis on démonte.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(_wrap(const SizedBox()));
    });
  });

  group('AmountDisplay', () {
    testWidgets('masque puis révèle le montant', (tester) async {
      await tester.pumpWidget(
        _wrap(const AmountDisplay(amount: 120000, revealed: false)),
      );
      expect(find.textContaining('120'), findsNothing);
      await tester.pumpWidget(
        _wrap(const AmountDisplay(amount: 120000, revealed: true)),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('120'), findsOneWidget);
    });
  });

  group('Boutons', () {
    testWidgets('PrimaryButton bloque le double envoi en loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            label: 'Confirmer',
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(PrimaryButton));
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('DestructiveButton déclenche onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          DestructiveButton(label: 'Se déconnecter', onPressed: () => taps++),
        ),
      );
      await tester.tap(find.text('Se déconnecter'));
      expect(taps, 1);
    });
  });
}
