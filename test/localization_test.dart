import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the delegate is available from the main library', () async {
    const delegate = DurationPickerLocalizations.delegate;

    expect(delegate.isSupported(const Locale('de')), isTrue);
    final german = await delegate.load(const Locale('de'));
    expect(german.baseUnitMinute, 'Min.');
  });
}
