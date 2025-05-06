// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redeemed_benefit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RedeemedBenefitImpl _$$RedeemedBenefitImplFromJson(
        Map<String, dynamic> json) =>
    _$RedeemedBenefitImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      benefitId: json['benefitId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String?,
      code: json['code'] as String,
      status: $enumDecode(_$BenefitStatusEnumMap, json['status']),
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.parse(json['usedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RedeemedBenefitImplToJson(
        _$RedeemedBenefitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'benefitId': instance.benefitId,
      'title': instance.title,
      'description': instance.description,
      if (instance.logoUrl case final value?) 'logoUrl': value,
      'code': instance.code,
      'status': _$BenefitStatusEnumMap[instance.status]!,
      'expirationDate': instance.expirationDate.toIso8601String(),
      'redeemedAt': instance.redeemedAt.toIso8601String(),
      if (instance.usedAt?.toIso8601String() case final value?) 'usedAt': value,
      'createdAt': instance.createdAt.toIso8601String(),
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };

const _$BenefitStatusEnumMap = {
  BenefitStatus.active: 'active',
  BenefitStatus.used: 'used',
  BenefitStatus.expired: 'expired',
};
