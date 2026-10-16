import 'dart:math' as math;

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _size = 300;
const double _radius = 100;

Future<List<Duration>> _pumpPicker(
  WidgetTester tester,
  Duration initial,
) async {
  final changes = <Duration>[];
  var duration = initial;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: StatefulBuilder(
            builder: (context, setState) => DurationPicker(
              width: _size,
              height: _size,
              duration: duration,
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

/// The point on the dial at [minutes], [radius] away from the centre.
Offset _pointAt(WidgetTester tester, double minutes, double radius) {
  final center = tester.getCenter(find.byType(DurationPicker));
  final theta = math.pi / 2 - minutes / 60 * 2 * math.pi;
  return center + Offset(math.cos(theta), -math.sin(theta)) * radius;
}

/// Starts a pan at [from] minutes and moves to [to] minutes in one update.
Future<void> _panJump(WidgetTester tester, double from, double to) async {
  final gesture = await tester.startGesture(_pointAt(tester, from, _radius));
  // Move radially past the touch slop so the pan starts without turning.
  await gesture.moveTo(_pointAt(tester, from, _radius - 30));
  await tester.pump();
  await gesture.moveTo(_pointAt(tester, to, _radius - 30));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a pan from 14 minutes can move past 15 minutes', (
    tester,
  ) async {
    final changes = await _pumpPicker(tester, const Duration(minutes: 14));

    await _panJump(tester, 14, 15.5);

    expect(changes.last, const Duration(minutes: 15));
  });

  testWidgets('a pan from 5 minutes can move to 20 minutes', (tester) async {
    final changes = await _pumpPicker(tester, const Duration(minutes: 5));

    await _panJump(tester, 5, 20.5);

    expect(changes.last, const Duration(minutes: 20));
  });

  testWidgets('panning back across zero does not wrap to 59 minutes', (
    tester,
  ) async {
    final changes = await _pumpPicker(tester, const Duration(minutes: 1));

    await _panJump(tester, 1, 59);

    expect(changes.last, const Duration(minutes: 1));
  });

  testWidgets('a far pan back from zero stays at zero', (tester) async {
    final changes = await _pumpPicker(tester, Duration.zero);

    await _panJump(tester, 0, 44);

    expect(changes.last, Duration.zero);
  });

  testWidgets('a tap on the dial selects that value', (tester) async {
    final changes = await _pumpPicker(tester, Duration.zero);

    await tester.tapAt(_pointAt(tester, 15.5, _radius));
    await tester.pumpAndSettle();

    expect(changes.last, const Duration(minutes: 15));
  });

  testWidgets('a tap keeps the full hours already selected', (tester) async {
    final changes = await _pumpPicker(
      tester,
      const Duration(hours: 1, minutes: 10),
    );

    await tester.tapAt(_pointAt(tester, 45.5, _radius));
    await tester.pumpAndSettle();

    expect(changes.last, const Duration(hours: 1, minutes: 45));
  });

  testWidgets('a drag on the dial inside a scroll view turns the dial', (
    tester,
  ) async {
    final changes = <Duration>[];
    var duration = const Duration(minutes: 15);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: controller,
            children: [
              StatefulBuilder(
                builder: (context, setState) => DurationPicker(
                  width: _size,
                  height: _size,
                  duration: duration,
                  onChange: (value) {
                    changes.add(value);
                    setState(() => duration = value);
                  },
                ),
              ),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );

    // Drag up along the ring from 15 towards 10 minutes, which would
    // otherwise scroll the list.
    final gesture = await tester.startGesture(_pointAt(tester, 15, _radius));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(-2, -4));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
    expect(changes.last, lessThan(const Duration(minutes: 15)));
  });
}
