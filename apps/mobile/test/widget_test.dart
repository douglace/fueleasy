import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/format/money.dart';
import 'package:fusy_mobile/main.dart';

void main() {
  final nbsp = String.fromCharCode(0xA0);

  test(
    'formatFcfa groups thousands with a non-breaking space and FCFA suffix',
    () {
      expect(formatFcfa(50000), '50${nbsp}000${nbsp}FCFA');
      expect(formatFcfa(15000), '15${nbsp}000${nbsp}FCFA');
      expect(formatFcfa(0), '0${nbsp}FCFA');
      expect(formatFcfa(1234567), '1${nbsp}234${nbsp}567${nbsp}FCFA');
    },
  );

  testWidgets('FusyApp builds and shows the foundations demo', (tester) async {
    await tester.pumpWidget(const FusyApp());
    expect(find.text('Fusy — Fondations'), findsOneWidget);
    expect(find.text('Scanner une station'), findsOneWidget);
  });
}
