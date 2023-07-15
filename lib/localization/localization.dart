import 'package:duration_picker/localization/en.dart';
import 'package:duration_picker/localization/ko.dart';
import 'package:flutter/material.dart';

abstract class DurationPickerLocalizations {
  String get baseUnitMillisecond;

  String get baseUnitSecond;

  String get baseUnitMinute;

  String get baseUnitHour;

  String get secondaryUnitMillisecond;

  String get secondaryUnitSecond;

  String get secondaryUnitMinute;

  String get secondaryUnitHour;

  static DurationPickerLocalizations of(BuildContext context) {
    return Localizations.of<DurationPickerLocalizations>(
          context,
          DurationPickerLocalizations,
        ) ??
        DurationPickerLocalizationsEn();
  }

  static const LocalizationsDelegate<DurationPickerLocalizations> delegate =
      _DurationPickerLocalizationDelegate();
}

class _DurationPickerLocalizationDelegate
    extends LocalizationsDelegate<DurationPickerLocalizations> {
  const _DurationPickerLocalizationDelegate();

  static const supportedLocales = ['en', 'ko'];

  @override
  bool isSupported(Locale locale) =>
      supportedLocales.contains(locale.languageCode);

  @override
  Future<DurationPickerLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ko':
        return DurationPickerLocalizationsKo();
      default:
        return DurationPickerLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_DurationPickerLocalizationDelegate old) => false;
}
