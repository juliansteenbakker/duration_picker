import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

void main() {
  LeakTesting.enable();

  testWidgets(
    'the dial disposes the text it paints',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      var duration = const Duration(minutes: 10);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => DurationPicker(
                  duration: duration,
                  onChange: (value) => setState(() => duration = value),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DurationPicker));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'the dialog disposes everything it creates',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDurationPicker(
                context: context,
                initialTime: const Duration(minutes: 10),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    },
  );
}
