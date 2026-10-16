import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Duration?> _openAndConfirm(
  WidgetTester tester, {
  required Duration initialTime,
  Duration? lowerBound,
  Duration? upperBound,
}) async {
  Duration? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showDurationPicker(
              context: context,
              initialTime: initialTime,
              lowerBound: lowerBound,
              upperBound: upperBound,
            );
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('an initial time below lowerBound is raised to it', (
    tester,
  ) async {
    final result = await _openAndConfirm(
      tester,
      initialTime: const Duration(minutes: 5),
      lowerBound: const Duration(minutes: 10),
    );

    expect(result, const Duration(minutes: 10));
  });

  testWidgets('an initial time above upperBound is lowered to it', (
    tester,
  ) async {
    final result = await _openAndConfirm(
      tester,
      initialTime: const Duration(minutes: 50),
      upperBound: const Duration(minutes: 30),
    );

    expect(result, const Duration(minutes: 30));
  });

  testWidgets('an initial time within the bounds is kept', (tester) async {
    final result = await _openAndConfirm(
      tester,
      initialTime: const Duration(minutes: 20),
      lowerBound: const Duration(minutes: 10),
      upperBound: const Duration(minutes: 30),
    );

    expect(result, const Duration(minutes: 20));
  });

  testWidgets('inverted bounds fail an assert', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DurationPicker(
          onChange: (_) {},
          lowerBound: const Duration(minutes: 30),
          upperBound: const Duration(minutes: 10),
        ),
      ),
    );

    expect(tester.takeException(), isA<AssertionError>());
  });
}
