import 'package:flutter_test/flutter_test.dart';
import 'package:drug_interaction_checker/utils/validators.dart';

void main() {
  group('Validators', () {
    group('medicationName', () {
      test('should return error for empty string', () {
        expect(Validators.medicationName(''), isNotNull);
        expect(Validators.medicationName(null), isNotNull);
      });

      test('should return error for too short name', () {
        expect(Validators.medicationName('A'), isNotNull);
      });

      test('should return error for too long name', () {
        final longName = 'A' * 101;
        expect(Validators.medicationName(longName), isNotNull);
      });

      test('should return null for valid name', () {
        expect(Validators.medicationName('Aspirin'), isNull);
        expect(Validators.medicationName('Warfarin'), isNull);
      });
    });

    group('dose', () {
      test('should return null for empty string (optional)', () {
        expect(Validators.dose(''), isNull);
        expect(Validators.dose(null), isNull);
      });

      test('should return error for non-numeric value', () {
        expect(Validators.dose('abc'), isNotNull);
        expect(Validators.dose('12abc'), isNotNull);
      });

      test('should return error for negative value', () {
        expect(Validators.dose('-5'), isNotNull);
      });

      test('should return error for zero', () {
        expect(Validators.dose('0'), isNotNull);
      });

      test('should return null for valid dose', () {
        expect(Validators.dose('100'), isNull);
        expect(Validators.dose('5.5'), isNull);
      });
    });

    group('email', () {
      test('should return error for empty string', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email(null), isNotNull);
      });

      test('should return error for invalid email', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('test@'), isNotNull);
        expect(Validators.email('@test.com'), isNotNull);
      });

      test('should return null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name@domain.co.uk'), isNull);
      });
    });

    group('age', () {
      test('should return null for empty string (optional)', () {
        expect(Validators.age(''), isNull);
        expect(Validators.age(null), isNull);
      });

      test('should return error for non-numeric value', () {
        expect(Validators.age('abc'), isNotNull);
      });

      test('should return error for invalid range', () {
        expect(Validators.age('-1'), isNotNull);
        expect(Validators.age('200'), isNotNull);
      });

      test('should return null for valid age', () {
        expect(Validators.age('25'), isNull);
        expect(Validators.age('65'), isNull);
        expect(Validators.age('0'), isNull);
        expect(Validators.age('150'), isNull);
      });
    });

    group('weight', () {
      test('should return null for empty string (optional)', () {
        expect(Validators.weight(''), isNull);
        expect(Validators.weight(null), isNull);
      });

      test('should return error for non-numeric value', () {
        expect(Validators.weight('abc'), isNotNull);
      });

      test('should return error for invalid range', () {
        expect(Validators.weight('0'), isNotNull);
        expect(Validators.weight('-5'), isNotNull);
        expect(Validators.weight('600'), isNotNull);
      });

      test('should return null for valid weight', () {
        expect(Validators.weight('70'), isNull);
        expect(Validators.weight('80.5'), isNull);
      });
    });
  });
}