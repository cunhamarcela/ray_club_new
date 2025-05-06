// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'redeemed_benefit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RedeemedBenefit _$RedeemedBenefitFromJson(Map<String, dynamic> json) {
  return _RedeemedBenefit.fromJson(json);
}

/// @nodoc
mixin _$RedeemedBenefit {
  /// Identificador único do resgate
  String get id => throw _privateConstructorUsedError;

  /// ID do benefício resgatado
  String get benefitId => throw _privateConstructorUsedError;

  /// ID do usuário que resgatou o benefício
  String get userId => throw _privateConstructorUsedError;

  /// Data e hora do resgate
  DateTime get redeemedAt => throw _privateConstructorUsedError;

  /// Código único do benefício resgatado (para verificação)
  String get redemptionCode => throw _privateConstructorUsedError;

  /// Data de expiração do resgate (quando aplicável)
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Status do resgate
  RedemptionStatus get status => throw _privateConstructorUsedError;

  /// Dados completos do benefício no momento do resgate
  Benefit? get benefitSnapshot => throw _privateConstructorUsedError;

  /// Dados adicionais específicos para o resgate
  Map<String, dynamic>? get additionalData =>
      throw _privateConstructorUsedError;

  /// Data de uso do benefício (quando foi consumido pelo usuário)
  DateTime? get usedAt => throw _privateConstructorUsedError;

  /// Serializes this RedeemedBenefit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedeemedBenefit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedeemedBenefitCopyWith<RedeemedBenefit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedeemedBenefitCopyWith<$Res> {
  factory $RedeemedBenefitCopyWith(
          RedeemedBenefit value, $Res Function(RedeemedBenefit) then) =
      _$RedeemedBenefitCopyWithImpl<$Res, RedeemedBenefit>;
  @useResult
  $Res call(
      {String id,
      String benefitId,
      String userId,
      DateTime redeemedAt,
      String redemptionCode,
      DateTime? expiresAt,
      RedemptionStatus status,
      Benefit? benefitSnapshot,
      Map<String, dynamic>? additionalData,
      DateTime? usedAt});

  $BenefitCopyWith<$Res>? get benefitSnapshot;
}

/// @nodoc
class _$RedeemedBenefitCopyWithImpl<$Res, $Val extends RedeemedBenefit>
    implements $RedeemedBenefitCopyWith<$Res> {
  _$RedeemedBenefitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedeemedBenefit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? benefitId = null,
    Object? userId = null,
    Object? redeemedAt = null,
    Object? redemptionCode = null,
    Object? expiresAt = freezed,
    Object? status = null,
    Object? benefitSnapshot = freezed,
    Object? additionalData = freezed,
    Object? usedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      benefitId: null == benefitId
          ? _value.benefitId
          : benefitId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      redeemedAt: null == redeemedAt
          ? _value.redeemedAt
          : redeemedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      redemptionCode: null == redemptionCode
          ? _value.redemptionCode
          : redemptionCode // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RedemptionStatus,
      benefitSnapshot: freezed == benefitSnapshot
          ? _value.benefitSnapshot
          : benefitSnapshot // ignore: cast_nullable_to_non_nullable
              as Benefit?,
      additionalData: freezed == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      usedAt: freezed == usedAt
          ? _value.usedAt
          : usedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of RedeemedBenefit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BenefitCopyWith<$Res>? get benefitSnapshot {
    if (_value.benefitSnapshot == null) {
      return null;
    }

    return $BenefitCopyWith<$Res>(_value.benefitSnapshot!, (value) {
      return _then(_value.copyWith(benefitSnapshot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RedeemedBenefitImplCopyWith<$Res>
    implements $RedeemedBenefitCopyWith<$Res> {
  factory _$$RedeemedBenefitImplCopyWith(_$RedeemedBenefitImpl value,
          $Res Function(_$RedeemedBenefitImpl) then) =
      __$$RedeemedBenefitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String benefitId,
      String userId,
      DateTime redeemedAt,
      String redemptionCode,
      DateTime? expiresAt,
      RedemptionStatus status,
      Benefit? benefitSnapshot,
      Map<String, dynamic>? additionalData,
      DateTime? usedAt});

  @override
  $BenefitCopyWith<$Res>? get benefitSnapshot;
}

/// @nodoc
class __$$RedeemedBenefitImplCopyWithImpl<$Res>
    extends _$RedeemedBenefitCopyWithImpl<$Res, _$RedeemedBenefitImpl>
    implements _$$RedeemedBenefitImplCopyWith<$Res> {
  __$$RedeemedBenefitImplCopyWithImpl(
      _$RedeemedBenefitImpl _value, $Res Function(_$RedeemedBenefitImpl) _then)
      : super(_value, _then);

  /// Create a copy of RedeemedBenefit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? benefitId = null,
    Object? userId = null,
    Object? redeemedAt = null,
    Object? redemptionCode = null,
    Object? expiresAt = freezed,
    Object? status = null,
    Object? benefitSnapshot = freezed,
    Object? additionalData = freezed,
    Object? usedAt = freezed,
  }) {
    return _then(_$RedeemedBenefitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      benefitId: null == benefitId
          ? _value.benefitId
          : benefitId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      redeemedAt: null == redeemedAt
          ? _value.redeemedAt
          : redeemedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      redemptionCode: null == redemptionCode
          ? _value.redemptionCode
          : redemptionCode // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RedemptionStatus,
      benefitSnapshot: freezed == benefitSnapshot
          ? _value.benefitSnapshot
          : benefitSnapshot // ignore: cast_nullable_to_non_nullable
              as Benefit?,
      additionalData: freezed == additionalData
          ? _value._additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      usedAt: freezed == usedAt
          ? _value.usedAt
          : usedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedeemedBenefitImpl implements _RedeemedBenefit {
  const _$RedeemedBenefitImpl(
      {required this.id,
      required this.benefitId,
      required this.userId,
      required this.redeemedAt,
      required this.redemptionCode,
      this.expiresAt,
      this.status = RedemptionStatus.active,
      this.benefitSnapshot,
      final Map<String, dynamic>? additionalData,
      this.usedAt})
      : _additionalData = additionalData;

  factory _$RedeemedBenefitImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedeemedBenefitImplFromJson(json);

  /// Identificador único do resgate
  @override
  final String id;

  /// ID do benefício resgatado
  @override
  final String benefitId;

  /// ID do usuário que resgatou o benefício
  @override
  final String userId;

  /// Data e hora do resgate
  @override
  final DateTime redeemedAt;

  /// Código único do benefício resgatado (para verificação)
  @override
  final String redemptionCode;

  /// Data de expiração do resgate (quando aplicável)
  @override
  final DateTime? expiresAt;

  /// Status do resgate
  @override
  @JsonKey()
  final RedemptionStatus status;

  /// Dados completos do benefício no momento do resgate
  @override
  final Benefit? benefitSnapshot;

  /// Dados adicionais específicos para o resgate
  final Map<String, dynamic>? _additionalData;

  /// Dados adicionais específicos para o resgate
  @override
  Map<String, dynamic>? get additionalData {
    final value = _additionalData;
    if (value == null) return null;
    if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Data de uso do benefício (quando foi consumido pelo usuário)
  @override
  final DateTime? usedAt;

  @override
  String toString() {
    return 'RedeemedBenefit(id: $id, benefitId: $benefitId, userId: $userId, redeemedAt: $redeemedAt, redemptionCode: $redemptionCode, expiresAt: $expiresAt, status: $status, benefitSnapshot: $benefitSnapshot, additionalData: $additionalData, usedAt: $usedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedeemedBenefitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.benefitId, benefitId) ||
                other.benefitId == benefitId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.redeemedAt, redeemedAt) ||
                other.redeemedAt == redeemedAt) &&
            (identical(other.redemptionCode, redemptionCode) ||
                other.redemptionCode == redemptionCode) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.benefitSnapshot, benefitSnapshot) ||
                other.benefitSnapshot == benefitSnapshot) &&
            const DeepCollectionEquality()
                .equals(other._additionalData, _additionalData) &&
            (identical(other.usedAt, usedAt) || other.usedAt == usedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      benefitId,
      userId,
      redeemedAt,
      redemptionCode,
      expiresAt,
      status,
      benefitSnapshot,
      const DeepCollectionEquality().hash(_additionalData),
      usedAt);

  /// Create a copy of RedeemedBenefit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedeemedBenefitImplCopyWith<_$RedeemedBenefitImpl> get copyWith =>
      __$$RedeemedBenefitImplCopyWithImpl<_$RedeemedBenefitImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedeemedBenefitImplToJson(
      this,
    );
  }
}

abstract class _RedeemedBenefit implements RedeemedBenefit {
  const factory _RedeemedBenefit(
      {required final String id,
      required final String benefitId,
      required final String userId,
      required final DateTime redeemedAt,
      required final String redemptionCode,
      final DateTime? expiresAt,
      final RedemptionStatus status,
      final Benefit? benefitSnapshot,
      final Map<String, dynamic>? additionalData,
      final DateTime? usedAt}) = _$RedeemedBenefitImpl;

  factory _RedeemedBenefit.fromJson(Map<String, dynamic> json) =
      _$RedeemedBenefitImpl.fromJson;

  /// Identificador único do resgate
  @override
  String get id;

  /// ID do benefício resgatado
  @override
  String get benefitId;

  /// ID do usuário que resgatou o benefício
  @override
  String get userId;

  /// Data e hora do resgate
  @override
  DateTime get redeemedAt;

  /// Código único do benefício resgatado (para verificação)
  @override
  String get redemptionCode;

  /// Data de expiração do resgate (quando aplicável)
  @override
  DateTime? get expiresAt;

  /// Status do resgate
  @override
  RedemptionStatus get status;

  /// Dados completos do benefício no momento do resgate
  @override
  Benefit? get benefitSnapshot;

  /// Dados adicionais específicos para o resgate
  @override
  Map<String, dynamic>? get additionalData;

  /// Data de uso do benefício (quando foi consumido pelo usuário)
  @override
  DateTime? get usedAt;

  /// Create a copy of RedeemedBenefit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedeemedBenefitImplCopyWith<_$RedeemedBenefitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
