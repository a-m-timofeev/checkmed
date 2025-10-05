import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  @JsonKey(name: 'is_premium')
  final bool isPremium;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.isPremium = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}