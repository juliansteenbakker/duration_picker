import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<TextScaler> _dialTextScaler(WidgetTester tester, double scale) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Center(child: DurationPicker(onChange: (_) {})),
        ),
      ),
    ),
  );
  final dial = tester.widget<CustomPaint>(
    find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter.runtimeType.toString() == '_DialPainter',
    ),
  );
  // The painter is private, so its public field is read dynamically.
  return (dial.painter! as dynamic).textScaler as TextScaler;
}

void main() {
  testWidgets('the dial follows the text scale', (tester) async {
    expect(await _dialTextScaler(tester, 1.3), const TextScaler.linear(1.3));
  });

  testWidgets('the dial caps the text scale so labels fit', (tester) async {
    expect(await _dialTextScaler(tester, 3), const TextScaler.linear(1.5));
  });
}
