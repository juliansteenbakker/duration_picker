import 'package:flutter/material.dart';

/// Colors and text styles for [DurationPicker] and [showDurationPicker].
///
/// Add it to [ThemeData.extensions] to style every picker in the app, or pass
/// it as `theme` to a single picker. Fields that are null fall back to the
/// app's [ColorScheme] and [TextTheme].
@immutable
class DurationPickerThemeData extends ThemeExtension<DurationPickerThemeData> {
  const DurationPickerThemeData({
    this.dialBackgroundColor,
    this.handColor,
    this.valueTextStyle,
    this.unitTextStyle,
    this.labelTextStyle,
  });

  /// The ring around the dial. Defaults to
  /// [ColorScheme.surfaceContainerHighest].
  final Color? dialBackgroundColor;

  /// The handle and the elapsed part of the ring. Defaults to
  /// [ColorScheme.primary].
  final Color? handColor;

  /// The selected value in the middle of the dial. Defaults to
  /// [TextTheme.displayMedium], scaled to the dial.
  final TextStyle? valueTextStyle;

  /// The unit below the selected value. Defaults to [TextTheme.bodyMedium].
  final TextStyle? unitTextStyle;

  /// The numbers around the dial. Defaults to [TextTheme.titleMedium].
  final TextStyle? labelTextStyle;

  /// Returns this theme with the non-null fields of [other] on top.
  DurationPickerThemeData merge(DurationPickerThemeData? other) {
    if (other == null) return this;
    return DurationPickerThemeData(
      dialBackgroundColor: other.dialBackgroundColor ?? dialBackgroundColor,
      handColor: other.handColor ?? handColor,
      valueTextStyle:
          valueTextStyle?.merge(other.valueTextStyle) ?? other.valueTextStyle,
      unitTextStyle:
          unitTextStyle?.merge(other.unitTextStyle) ?? other.unitTextStyle,
      labelTextStyle:
          labelTextStyle?.merge(other.labelTextStyle) ?? other.labelTextStyle,
    );
  }

  @override
  DurationPickerThemeData copyWith({
    Color? dialBackgroundColor,
    Color? handColor,
    TextStyle? valueTextStyle,
    TextStyle? unitTextStyle,
    TextStyle? labelTextStyle,
  }) {
    return DurationPickerThemeData(
      dialBackgroundColor: dialBackgroundColor ?? this.dialBackgroundColor,
      handColor: handColor ?? this.handColor,
      valueTextStyle: valueTextStyle ?? this.valueTextStyle,
      unitTextStyle: unitTextStyle ?? this.unitTextStyle,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
    );
  }

  @override
  DurationPickerThemeData lerp(
    covariant DurationPickerThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    return DurationPickerThemeData(
      dialBackgroundColor:
          Color.lerp(dialBackgroundColor, other.dialBackgroundColor, t),
      handColor: Color.lerp(handColor, other.handColor, t),
      valueTextStyle: TextStyle.lerp(valueTextStyle, other.valueTextStyle, t),
      unitTextStyle: TextStyle.lerp(unitTextStyle, other.unitTextStyle, t),
      labelTextStyle: TextStyle.lerp(labelTextStyle, other.labelTextStyle, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DurationPickerThemeData &&
        other.dialBackgroundColor == dialBackgroundColor &&
        other.handColor == handColor &&
        other.valueTextStyle == valueTextStyle &&
        other.unitTextStyle == unitTextStyle &&
        other.labelTextStyle == labelTextStyle;
  }

  @override
  int get hashCode => Object.hash(
        dialBackgroundColor,
        handColor,
        valueTextStyle,
        unitTextStyle,
        labelTextStyle,
      );
}
