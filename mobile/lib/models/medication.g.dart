// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'medication.dart';

Medication _$MedicationFromJson(Map<String, dynamic> json) => Medication(
      id: json['id'] as String?,
      name: json['name'] as String,
      dose: json['dose'] as String?,
      unit: json['unit'] as String?,
      frequency: json['frequency'] as String?,
      time: json['time'] as String?,
      route: json['route'] as String?,
      externalIds: (json['external_ids'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$MedicationToJson(Medication instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['name'] = instance.name;
  writeNotNull('dose', instance.dose);
  writeNotNull('unit', instance.unit);
  writeNotNull('frequency', instance.frequency);
  writeNotNull('time', instance.time);
  writeNotNull('route', instance.route);
  writeNotNull('external_ids', instance.externalIds);
  return val;
}