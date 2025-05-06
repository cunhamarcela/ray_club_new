// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardDataImpl _$$DashboardDataImplFromJson(Map<String, dynamic> json) =>
    _$DashboardDataImpl(
      userProgress:
          UserProgress.fromJson(json['userProgress'] as Map<String, dynamic>),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      currentChallenge: json['currentChallenge'] == null
          ? null
          : Challenge.fromJson(
              json['currentChallenge'] as Map<String, dynamic>),
      challengeProgress: json['challengeProgress'] == null
          ? null
          : ChallengeProgress.fromJson(
              json['challengeProgress'] as Map<String, dynamic>),
      redeemedBenefits: (json['redeemedBenefits'] as List<dynamic>?)
              ?.map((e) => RedeemedBenefit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      additionalData:
          json['additionalData'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$DashboardDataImplToJson(_$DashboardDataImpl instance) =>
    <String, dynamic>{
      'userProgress': instance.userProgress.toJson(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      if (instance.currentChallenge?.toJson() case final value?)
        'currentChallenge': value,
      if (instance.challengeProgress?.toJson() case final value?)
        'challengeProgress': value,
      'redeemedBenefits':
          instance.redeemedBenefits.map((e) => e.toJson()).toList(),
      'additionalData': instance.additionalData,
    };
