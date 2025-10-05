import 'package:json_annotation/json_annotation.dart';

part 'check_result.g.dart';

@JsonSerializable()
class CheckResult {
  @JsonKey(name: 'job_id')
  final String jobId;
  final String status;
  final String? summary;
  final InteractionCategories? categories;
  @JsonKey(name: 'confidence_score')
  final double? confidenceScore;
  final List<SourceReference>? sources;

  CheckResult({
    required this.jobId,
    required this.status,
    this.summary,
    this.categories,
    this.confidenceScore,
    this.sources,
  });

  factory CheckResult.fromJson(Map<String, dynamic> json) => _$CheckResultFromJson(json);
  Map<String, dynamic> toJson() => _$CheckResultToJson(this);
}

@JsonSerializable()
class InteractionCategories {
  final List<DrugInteraction> danger;
  final List<DrugInteraction> caution;
  final List<DrugInteraction> recommendation;

  InteractionCategories({
    this.danger = const [],
    this.caution = const [],
    this.recommendation = const [],
  });

  factory InteractionCategories.fromJson(Map<String, dynamic> json) => _$InteractionCategoriesFromJson(json);
  Map<String, dynamic> toJson() => _$InteractionCategoriesToJson(this);
}

@JsonSerializable()
class DrugInteraction {
  final List<String> meds;
  final String category;
  @JsonKey(name: 'short_summary')
  final String shortSummary;
  final String mechanism;
  @JsonKey(name: 'symptoms_to_monitor')
  final List<String> symptomsToMonitor;
  final List<EvidenceItem> evidence;
  @JsonKey(name: 'suggested_action')
  final String suggestedAction;
  final double confidence;

  DrugInteraction({
    required this.meds,
    required this.category,
    required this.shortSummary,
    required this.mechanism,
    this.symptomsToMonitor = const [],
    this.evidence = const [],
    required this.suggestedAction,
    required this.confidence,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) => _$DrugInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$DrugInteractionToJson(this);
}

@JsonSerializable()
class EvidenceItem {
  final String source;
  final String id;
  final String quote;

  EvidenceItem({
    required this.source,
    required this.id,
    required this.quote,
  });

  factory EvidenceItem.fromJson(Map<String, dynamic> json) => _$EvidenceItemFromJson(json);
  Map<String, dynamic> toJson() => _$EvidenceItemToJson(this);
}

@JsonSerializable()
class SourceReference {
  final String type;
  final String url;

  SourceReference({
    required this.type,
    required this.url,
  });

  factory SourceReference.fromJson(Map<String, dynamic> json) => _$SourceReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$SourceReferenceToJson(this);
}