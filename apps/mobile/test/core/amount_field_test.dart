import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/widgets/amount_field.dart';

void main() {
  final nbsp = String.fromCharCode(0xA0);

  testWidgets('AmountField groups thousands live and reports the raw amount', (
    tester,
  ) async {
    final controller = TextEditingController();
    int? reported;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AmountField(
            controller: controller,
            onAmountChanged: (v) => reported = v,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '15000');
    await tester.pump();

    expect(controller.text, '15${nbsp}000');
    expect(reported, 15000);
  });

  testWidgets('AmountField reports null once cleared', (tester) async {
    final controller = TextEditingController();
    int? reported = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AmountField(
            controller: controller,
            onAmountChanged: (v) => reported = v,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '5000');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(controller.text, '');
    expect(reported, isNull);
  });
}
