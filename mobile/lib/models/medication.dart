import 'package:json_annotation/json_annotation.dart';

part 'medication.g.dart';

@JsonSerializable()
class Medication {
  final String? id;
  final String name;
  final String? dose;
  final String? unit;
  final String? frequency;
  final String? time;
  final String? route;
  @JsonKey(name: 'external_ids')
  final Map<String, String>? externalIds;

  Medication({
    this.id,
    required this.name,
    this.dose,
    this.unit,
    this.frequency,
    this.time,
    this.route,
    this.externalIds,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => _$MedicationFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationToJson(this);
  
  Medication copyWith({
    String? id,
    String? name,
    String? dose,
    String? unit,
    String? frequency,
    String? time,
    String? route,
    Map<String, String>? externalIds,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      route: route ?? this.route,
      externalIds: externalIds ?? this.externalIds,
    );
  }
}