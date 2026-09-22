import 'package:duration_picker/duration_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('showDurationPicker opens when MaterialApp comes from material_ui', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                showDurationPicker(
                  context: context,
                  initialTime: const Duration(minutes: 10),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(DurationPickerDialog), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
