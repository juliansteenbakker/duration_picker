import 'dart:math' as math;

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _radius = 100;

class _Host extends StatefulWidget {
  const _Host({
    super.key,
    required this.initial,
    this.adjust = _identity,
  });

  final Duration initial;

  /// Applied to every change before it is passed back to the picker.
  final Duration Function(Duration) adjust;

  static Duration _identity(Duration value) => value;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late Duration duration = widget.initial;
  Duration? upperBound;

  void update({Duration? duration, Duration? upperBound}) {
    setState(() {
      this.duration = duration ?? this.duration;
      this.upperBound = upperBound ?? this.upperBound;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DurationPicker(
      width: 300,
      height: 300,
      duration: duration,
      upperBound: upperBound,
      onChange: (value) => setState(() => duration = widget.adjust(value)),
    );
  }
}

Future<_HostState> _pumpHost(
  WidgetTester tester,
  Duration initial, {
  Duration Function(Duration)? adjust,
}) async {
  final key = GlobalKey<_HostState>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: adjust == null
              ? _Host(key: key, initial: initial)
              : _Host(key: key, initial: initial, adjust: adjust),
        ),
      ),
    ),
  );
  return key.currentState!;
}

Offset _pointAt(WidgetTester tester, double minutes, double radius) {
  final center = tester.getCenter(find.byType(DurationPicker));
  final theta = math.pi / 2 - minutes / 60 * 2 * math.pi;
  return center + Offset(math.cos(theta), -math.sin(theta)) * radius;
}

/// Pans from [from] to [to] minutes in steps of one minute.
Future<void> _panSteps(WidgetTester tester, double from, double to) async {
  final gesture = await tester.startGesture(_pointAt(tester, from, _radius));
  await gesture.moveTo(_pointAt(tester, from, _radius - 30));
  await tester.pump();
  for (var m = from + 1; m <= to; m++) {
    await gesture.moveTo(_pointAt(tester, m, _radius - 30));
    await tester.pump();
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a tap after an outside change keeps the new hours', (
    tester,
  ) async {
    final host = await _pumpHost(tester, const Duration(minutes: 10));

    host.update(duration: const Duration(hours: 1, minutes: 20));
    await tester.pump();
    await tester.tapAt(_pointAt(tester, 30.5, _radius));
    await tester.pumpAndSettle();

    expect(host.duration, const Duration(hours: 1, minutes: 30));
  });

  testWidgets('a pan after an outside change starts from the new value', (
    tester,
  ) async {
    final host = await _pumpHost(tester, const Duration(minutes: 10));

    host.update(duration: const Duration(hours: 1, minutes: 20));
    await tester.pump();
    await _panSteps(tester, 20, 25.5);

    expect(host.duration, const Duration(hours: 1, minutes: 25));
  });

  testWidgets('a pan still moves when the parent rounds the value', (
    tester,
  ) async {
    final host = await _pumpHost(
      tester,
      Duration.zero,
      adjust: (value) => Duration(minutes: value.inMinutes ~/ 5 * 5),
    );

    await _panSteps(tester, 0, 22.5);

    expect(host.duration, const Duration(minutes: 20));
  });

  testWidgets('an upperBound set after the first build is applied', (
    tester,
  ) async {
    final host = await _pumpHost(tester, const Duration(minutes: 10));

    host.update(upperBound: const Duration(minutes: 30));
    await tester.pump();
    await _panSteps(tester, 10, 45.5);

    expect(host.duration, const Duration(minutes: 30));
  });
}
