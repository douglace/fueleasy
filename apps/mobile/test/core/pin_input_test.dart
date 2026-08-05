import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/widgets/pin_input.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

/// Nombre de pastilles visibles (cercles masquant les chiffres) dans les cases.
int _dotCount(WidgetTester tester) {
  return tester
      .widgetList<Container>(find.byType(Container))
      .where(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).shape == BoxShape.circle,
      )
      .length;
}

void main() {
  group('PinInput', () {
    testWidgets('déclenche onCompleted quand le code est complet', (
      tester,
    ) async {
      String? completed;
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(
          PinInput(controller: controller, onCompleted: (v) => completed = v),
        ),
      );

      await tester.enterText(find.byType(TextField), '123');
      expect(completed, isNull);
      await tester.enterText(find.byType(TextField), '1234');
      expect(completed, '1234');

      controller.dispose();
    });

    testWidgets('ignore les caractères non numériques et plafonne la taille', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrap(PinInput(controller: controller)));

      await tester.enterText(find.byType(TextField), '1a2b3c4d5e');
      expect(controller.text, '1234');

      controller.dispose();
    });

    testWidgets(
      'masque les chiffres par défaut, les affiche si obscure=false',
      (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(_wrap(PinInput(controller: controller)));

        await tester.enterText(find.byType(TextField), '7');
        await tester.pump();
        expect(_dotCount(tester), 1);

        await tester.pumpWidget(
          _wrap(PinInput(controller: controller, obscure: false)),
        );
        await tester.pump();
        expect(_dotCount(tester), 0);
        final visible = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data)
            .toList();
        expect(visible, contains('7'));

        controller.dispose();
      },
    );

    testWidgets('affiche la case active (curseur) sur la position courante', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(PinInput(controller: controller, autofocus: true)),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      expect(_dotCount(tester), 2);

      controller.dispose();
    });

    testWidgets('rend 4 emplacements soulignés, plafonnés et centrés', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 328, child: PinInput(controller: controller)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // Un trait animé (AnimatedContainer) par emplacement.
      final underlines = tester
          .widgetList<AnimatedContainer>(
            find.descendant(
              of: find.byType(PinInput),
              matching: find.byType(AnimatedContainer),
            ),
          )
          .toList();
      expect(underlines.length, 4);

      // Rangée centrée : le premier emplacement ne colle pas au bord gauche.
      final inputTopLeft = tester.getTopLeft(find.byType(PinInput));
      final firstUnderlineTopLeft = tester.getTopLeft(
        find
            .descendant(
              of: find.byType(PinInput),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(firstUnderlineTopLeft.dx - inputTopLeft.dx, greaterThan(20));

      controller.dispose();
    });
  });
}
