import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<Duration>> _pumpPicker(
  WidgetTester tester,
  Duration initial, {
  Duration? lowerBound,
  Duration? upperBound,
}) async {
  final changes = <Duration>[];
  var duration = initial;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: StatefulBuilder(
            builder: (context, setState) => DurationPicker(
              duration: duration,
              lowerBound: lowerBound,
              upperBound: upperBound,
              onChange: (value) {
                changes.add(value);
                setState(() => duration = value);
              },
            ),
          ),
        ),
      ),
    ),
  );
  return changes;
}

SemanticsNode _dialNode(WidgetTester tester) => tester.getSemantics(
      find.descendant(
        of: find.byType(DurationPicker),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && (widget.properties.slider ?? false),
        ),
      ),
    );

Future<void> _perform(WidgetTester tester, SemanticsAction action) async {
  tester.binding.performSemanticsAction(
    SemanticsActionEvent(
      type: action,
      viewId: tester.view.viewId,
      nodeId: _dialNode(tester).id,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the dial reads as a slider with its value', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpPicker(tester, const Duration(hours: 1, minutes: 25));

    expect(
      _dialNode(tester),
      matchesSemantics(
        isSlider: true,
        value: '1h 25 min.',
        increasedValue: '1h 26 min.',
        decreasedValue: '1h 24 min.',
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('increase and decrease change the value by one unit', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final changes = await _pumpPicker(tester, const Duration(minutes: 59));

    await _perform(tester, SemanticsAction.increase);
    expect(changes.last, const Duration(hours: 1));

    await _perform(tester, SemanticsAction.decrease);
    await _perform(tester, SemanticsAction.decrease);
    expect(changes.last, const Duration(minutes: 58));
    handle.dispose();
  });

  testWidgets('the actions stop at the bounds', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpPicker(
      tester,
      const Duration(minutes: 10),
      lowerBound: const Duration(minutes: 10),
      upperBound: const Duration(minutes: 11),
    );

    expect(
      _dialNode(tester),
      matchesSemantics(
        isSlider: true,
        value: '10 min.',
        increasedValue: '11 min.',
        hasIncreaseAction: true,
      ),
    );

    await _perform(tester, SemanticsAction.increase);
    expect(
      _dialNode(tester),
      matchesSemantics(
        isSlider: true,
        value: '11 min.',
        decreasedValue: '10 min.',
        hasDecreaseAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('the value cannot be decreased below zero', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpPicker(tester, Duration.zero);

    expect(
      _dialNode(tester),
      matchesSemantics(
        isSlider: true,
        value: '0 min.',
        increasedValue: '1 min.',
        hasIncreaseAction: true,
      ),
    );
    handle.dispose();
  });
}
