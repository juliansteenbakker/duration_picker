import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _theme = ThemeData(colorSchemeSeed: Colors.indigo);

Future<void> _pumpPicker(
  WidgetTester tester, {
  DurationPickerThemeData? appTheme,
  DurationPickerThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: _theme.copyWith(
        extensions: [if (appTheme != null) appTheme],
      ),
      home: Scaffold(
        body: Center(
          child: DurationPicker(
            duration: const Duration(minutes: 20),
            onChange: (_) {},
            theme: theme,
          ),
        ),
      ),
    ),
  );
}

Finder get _dial => find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter.runtimeType.toString() == '_DialPainter',
    );

/// Matches the ring, then the handle, in the order the dial paints them.
PaintPattern _paintsDial({required Color ring, required Color hand}) {
  return paints
    ..circle(color: ring, style: PaintingStyle.stroke)
    ..circle(color: hand, radius: 20);
}

void main() {
  testWidgets('the dial follows the color scheme by default', (tester) async {
    await _pumpPicker(tester);

    expect(
      _dial,
      _paintsDial(
        ring: _theme.colorScheme.surfaceContainerHighest,
        hand: _theme.colorScheme.primary,
      ),
    );
  });

  testWidgets('the theme extension styles the dial', (tester) async {
    await _pumpPicker(
      tester,
      appTheme: const DurationPickerThemeData(
        dialBackgroundColor: Colors.amber,
        handColor: Colors.teal,
      ),
    );

    expect(_dial, _paintsDial(ring: Colors.amber, hand: Colors.teal));
  });

  testWidgets('the theme parameter overrides the extension per field', (
    tester,
  ) async {
    await _pumpPicker(
      tester,
      appTheme: const DurationPickerThemeData(
        dialBackgroundColor: Colors.amber,
        handColor: Colors.teal,
      ),
      theme: const DurationPickerThemeData(handColor: Colors.red),
    );

    expect(_dial, _paintsDial(ring: Colors.amber, hand: Colors.red));
  });

  testWidgets('showDurationPicker passes the theme to the dial', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDurationPicker(
              context: context,
              initialTime: const Duration(minutes: 20),
              theme: const DurationPickerThemeData(handColor: Colors.red),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(
      _dial,
      _paintsDial(
        ring: _theme.colorScheme.surfaceContainerHighest,
        hand: Colors.red,
      ),
    );
  });

  test('merge keeps fields the other theme leaves null', () {
    const base = DurationPickerThemeData(
      handColor: Colors.teal,
      labelTextStyle: TextStyle(fontSize: 12),
    );
    final merged = base.merge(
      const DurationPickerThemeData(
        labelTextStyle: TextStyle(color: Colors.red),
      ),
    );

    expect(merged.handColor, Colors.teal);
    expect(merged.labelTextStyle!.fontSize, 12);
    expect(merged.labelTextStyle!.color, Colors.red);
  });
}
