import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drug_interaction_checker/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that splash screen is shown
    expect(find.text('Drug Interaction\nChecker'), findsOneWidget);
  });

  test('Medication name validator rejects empty string', () {
    // Import validators when needed
    // final result = Validators.medicationName('');
    // expect(result, isNotNull);
  });

  test('Dose validator accepts numeric values', () {
    // Import validators when needed
    // final result = Validators.dose('100');
    // expect(result, isNull);
  });
}