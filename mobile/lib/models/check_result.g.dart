// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'check_result.dart';

CheckResult _$CheckResultFromJson(Map<String, dynamic> json) => CheckResult(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
      summary: json['summary'] as String?,
      categories: json['categories'] == null
          ? null
          : InteractionCategories.fromJson(
              json['categories'] as Map<String, dynamic>),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => SourceReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CheckResultToJson(CheckResult instance) =>
    <String, dynamic>{
      'job_id': instance.jobId,
      'status': instance.status,
      'summary': instance.summary,
      'categories': instance.categories,
      'confidence_score': instance.confidenceScore,
      'sources': instance.sources,
    };

InteractionCategories _$InteractionCategoriesFromJson(
        Map<String, dynamic> json) =>
    InteractionCategories(
      danger: (json['danger'] as List<dynamic>?)
              ?.map((e) => DrugInteraction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      caution: (json['caution'] as List<dynamic>?)
              ?.map((e) => DrugInteraction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendation: (json['recommendation'] as List<dynamic>?)
              ?.map((e) => DrugInteraction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$InteractionCategoriesToJson(
        InteractionCategories instance) =>
    <String, dynamic>{
      'danger': instance.danger,
      'caution': instance.caution,
      'recommendation': instance.recommendation,
    };

DrugInteraction _$DrugInteractionFromJson(Map<String, dynamic> json) =>
    DrugInteraction(
      meds: (json['meds'] as List<dynamic>).map((e) => e as String).toList(),
      category: json['category'] as String,
      shortSummary: json['short_summary'] as String,
      mechanism: json['mechanism'] as String,
      symptomsToMonitor: (json['symptoms_to_monitor'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => EvidenceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      suggestedAction: json['suggested_action'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$DrugInteractionToJson(DrugInteraction instance) =>
    <String, dynamic>{
      'meds': instance.meds,
      'category': instance.category,
      'short_summary': instance.shortSummary,
      'mechanism': instance.mechanism,
      'symptoms_to_monitor': instance.symptomsToMonitor,
      'evidence': instance.evidence,
      'suggested_action': instance.suggestedAction,
      'confidence': instance.confidence,
    };

EvidenceItem _$EvidenceItemFromJson(Map<String, dynamic> json) => EvidenceItem(
      source: json['source'] as String,
      id: json['id'] as String,
      quote: json['quote'] as String,
    );

Map<String, dynamic> _$EvidenceItemToJson(EvidenceItem instance) =>
    <String, dynamic>{
      'source': instance.source,
      'id': instance.id,
      'quote': instance.quote,
    };

SourceReference _$SourceReferenceFromJson(Map<String, dynamic> json) =>
    SourceReference(
      type: json['type'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$SourceReferenceToJson(SourceReference instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
    };