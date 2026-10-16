import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openWithTitle(WidgetTester tester, Size viewSize) async {
  tester.view.physicalSize = viewSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDurationPicker(
            context: context,
            initialTime: const Duration(minutes: 20),
            title: const Text('Snooze for'),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the title is shown above the dial in portrait', (
    tester,
  ) async {
    await _openWithTitle(tester, const Size(400, 800));

    expect(find.text('Snooze for'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the title fits in landscape', (tester) async {
    await _openWithTitle(tester, const Size(800, 400));

    expect(find.text('Snooze for'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
