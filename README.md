# Duration Picker for Flutter

A widget for picking durations, inspired by the Material Design time picker. Drag the handle around the dial or tap a value to select it; every full turn adds one unit to the larger unit, so a minute dial counts hours as you keep turning.

Forked from [flutter_duration_picker](https://github.com/cdharris/flutter_duration_picker).

<p>
  <img src="https://raw.githubusercontent.com/juliansteenbakker/duration_picker/master/doc/screenshots/inline.png" width="320" alt="Inline duration picker set to 1 hour 25 minutes">
  <img src="https://raw.githubusercontent.com/juliansteenbakker/duration_picker/master/doc/screenshots/dialog.png" width="320" alt="Duration picker dialog with a title">
</p>

## Installation

```sh
flutter pub add duration_picker
```

## Usage

### Dialog

`showDurationPicker` opens the picker in a dialog and returns the selected duration, or `null` when the user cancels.

```dart
final duration = await showDurationPicker(
  context: context,
  initialTime: const Duration(minutes: 30),
  title: const Text('Snooze for'),
);
if (!context.mounted || duration == null) return;
```

### Inline

`DurationPicker` embeds the dial in your own layout. It works inside scroll views as well.

```dart
class _MyWidgetState extends State<MyWidget> {
  Duration _duration = const Duration(minutes: 30);

  @override
  Widget build(BuildContext context) {
    return DurationPicker(
      duration: _duration,
      onChange: (value) => setState(() => _duration = value),
    );
  }
}
```

### Options

| Option | Available on | Description |
| --- | --- | --- |
| `baseUnit` | both | The unit of the dial: `BaseUnit.millisecond`, `second`, `minute` (default) or `hour`. With `BaseUnit.hour` a full turn is a day. |
| `lowerBound`, `upperBound` | both | Limit the duration that can be selected. The dialog clamps an `initialTime` outside the bounds. |
| `title` | dialog | A widget shown above the dial. |
| `decoration` | dialog | A `BoxDecoration` for the dialog's content. |
| `width`, `height` | inline | The size of the picker. |
| `theme` | both | A `DurationPickerThemeData` for this picker only. See [Theming](#theming). |

## Theming

The picker follows your app's `ColorScheme` and `TextTheme`. To change its colors or text styles everywhere, add a `DurationPickerThemeData` to your theme's extensions:

```dart
MaterialApp(
  theme: ThemeData(
    colorSchemeSeed: Colors.indigo,
    extensions: const [
      DurationPickerThemeData(
        handColor: Colors.teal,
        labelTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
);
```

Pass one as `theme` to style a single picker; its fields take precedence over the app-wide ones.

| Field | Default |
| --- | --- |
| `dialBackgroundColor` | `ColorScheme.surfaceContainerHighest`, or a light grey with `useMaterial3: false` |
| `handColor` | `ColorScheme.primary` |
| `valueTextStyle` | `TextTheme.displayMedium`, sized to the dial |
| `unitTextStyle` | `TextTheme.bodyMedium` |
| `labelTextStyle` | `TextTheme.titleMedium` |

## Localization

The unit labels are available in English, German and Korean, and fall back to English. To use the device language, add the picker's delegate to your app:

```dart
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  localizationsDelegates: const [
    DurationPickerLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en'), Locale('de'), Locale('ko')],
);
```

This needs `flutter_localizations` in your dependencies:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

### Adding a language

Contributions for other languages are welcome:

1. Add a class extending `DurationPickerLocalizations` in `lib/localization/`, like `DurationPickerLocalizationsDe` in `de.dart`.
2. Add the language code to `supportedLocales` in `_DurationPickerLocalizationDelegate` and return your class from its `load` method.
