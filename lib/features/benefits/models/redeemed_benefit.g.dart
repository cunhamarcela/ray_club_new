// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redeemed_benefit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RedeemedBenefitImpl _$$RedeemedBenefitImplFromJson(
        Map<String, dynamic> json) =>
    _$RedeemedBenefitImpl(
      id: json['id'] as String,
      benefitId: json['benefitId'] as String,
      userId: json['userId'] as String,
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
      redemptionCode: json['redemptionCode'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      status: $enumDecodeNullable(_$RedemptionStatusEnumMap, json['status']) ??
          RedemptionStatus.active,
      benefitSnapshot: json['benefitSnapshot'] == null
          ? null
          : Benefit.fromJson(json['benefitSnapshot'] as Map<String, dynamic>),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.parse(json['usedAt'] as String),
    );

Map<String, dynamic> _$$RedeemedBenefitImplToJson(
        _$RedeemedBenefitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'benefitId': instance.benefitId,
      'userId': instance.userId,
      'redeemedAt': instance.redeemedAt.toIso8601String(),
      'redemptionCode': instance.redemptionCode,
      if (instance.expiresAt?.toIso8601String() case final value?)
        'expiresAt': value,
      'status': _$RedemptionStatusEnumMap[instance.status]!,
      if (instance.benefitSnapshot?.toJson() case final value?)
        'benefitSnapshot': value,
      if (instance.additionalData case final value?) 'additionalData': value,
      if (instance.usedAt?.toIso8601String() case final value?) 'usedAt': value,
    };

const _$RedemptionStatusEnumMap = {
  RedemptionStatus.active: 'active',
  RedemptionStatus.used: 'used',
  RedemptionStatus.expired: 'expired',
  RedemptionStatus.cancelled: 'cancelled',
};
