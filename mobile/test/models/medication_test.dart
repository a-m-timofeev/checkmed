import 'package:flutter_test/flutter_test.dart';
import 'package:drug_interaction_checker/models/medication.dart';

void main() {
  group('Medication Model', () {
    test('should create medication from JSON', () {
      final json = {
        'id': '123',
        'name': 'Aspirin',
        'dose': '100',
        'unit': 'mg',
        'frequency': 'once_daily',
        'route': 'oral',
      };

      final medication = Medication.fromJson(json);

      expect(medication.id, '123');
      expect(medication.name, 'Aspirin');
      expect(medication.dose, '100');
      expect(medication.unit, 'mg');
      expect(medication.frequency, 'once_daily');
      expect(medication.route, 'oral');
    });

    test('should convert medication to JSON', () {
      final medication = Medication(
        id: '123',
        name: 'Warfarin',
        dose: '5',
        unit: 'mg',
        frequency: 'once_daily',
        route: 'oral',
      );

      final json = medication.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Warfarin');
      expect(json['dose'], '5');
      expect(json['unit'], 'mg');
    });

    test('should create copy with new values', () {
      final original = Medication(
        id: '123',
        name: 'Aspirin',
        dose: '100',
        unit: 'mg',
      );

      final copy = original.copyWith(dose: '200');

      expect(copy.id, '123');
      expect(copy.name, 'Aspirin');
      expect(copy.dose, '200');
      expect(copy.unit, 'mg');
    });
  });
}