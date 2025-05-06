// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'redeemed_benefit_model.dart';

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
  /// ID único do benefício resgatado
  String get id => throw _privateConstructorUsedError;

  /// ID do usuário que resgatou
  String get userId => throw _privateConstructorUsedError;

  /// ID do benefício original
  String get benefitId => throw _privateConstructorUsedError;

  /// Título do benefício
  String get title => throw _privateConstructorUsedError;

  /// Descrição do benefício
  String get description => throw _privateConstructorUsedError;

  /// URL da imagem/logo do benefício (opcional)
  String? get logoUrl => throw _privateConstructorUsedError;

  /// Código do benefício (para uso/resgate)
  String get code => throw _privateConstructorUsedError;

  /// Status atual do benefício
  BenefitStatus get status => throw _privateConstructorUsedError;

  /// Data de expiração do benefício
  DateTime get expirationDate => throw _privateConstructorUsedError;

  /// Data em que o benefício foi resgatado
  DateTime get redeemedAt => throw _privateConstructorUsedError;

  /// Data em que o benefício foi utilizado
  DateTime? get usedAt => throw _privateConstructorUsedError;

  /// Data de criação do registro
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Data da última atualização
  DateTime? get updatedAt => throw _privateConstructorUsedError;

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
      String userId,
      String benefitId,
      String title,
      String description,
      String? logoUrl,
      String code,
      BenefitStatus status,
      DateTime expirationDate,
      DateTime redeemedAt,
      DateTime? usedAt,
      DateTime createdAt,
      DateTime? updatedAt});
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
    Object? userId = null,
    Object? benefitId = null,
    Object? title = null,
    Object? description = null,
    Object? logoUrl = freezed,
    Object? code = null,
    Object? status = null,
    Object? expirationDate = null,
    Object? redeemedAt = null,
    Object? usedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      benefitId: null == benefitId
          ? _value.benefitId
          : benefitId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BenefitStatus,
      expirationDate: null == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      redeemedAt: null == redeemedAt
          ? _value.redeemedAt
          : redeemedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      usedAt: freezed == usedAt
          ? _value.usedAt
          : usedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
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
      String userId,
      String benefitId,
      String title,
      String description,
      String? logoUrl,
      String code,
      BenefitStatus status,
      DateTime expirationDate,
      DateTime redeemedAt,
      DateTime? usedAt,
      DateTime createdAt,
      DateTime? updatedAt});
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
    Object? userId = null,
    Object? benefitId = null,
    Object? title = null,
    Object? description = null,
    Object? logoUrl = freezed,
    Object? code = null,
    Object? status = null,
    Object? expirationDate = null,
    Object? redeemedAt = null,
    Object? usedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$RedeemedBenefitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      benefitId: null == benefitId
          ? _value.benefitId
          : benefitId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BenefitStatus,
      expirationDate: null == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      redeemedAt: null == redeemedAt
          ? _value.redeemedAt
          : redeemedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      usedAt: freezed == usedAt
          ? _value.usedAt
          : usedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedeemedBenefitImpl extends _RedeemedBenefit {
  const _$RedeemedBenefitImpl(
      {required this.id,
      required this.userId,
      required this.benefitId,
      required this.title,
      required this.description,
      this.logoUrl,
      required this.code,
      required this.status,
      required this.expirationDate,
      required this.redeemedAt,
      this.usedAt,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$RedeemedBenefitImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedeemedBenefitImplFromJson(json);

  /// ID único do benefício resgatado
  @override
  final String id;

  /// ID do usuário que resgatou
  @override
  final String userId;

  /// ID do benefício original
  @override
  final String benefitId;

  /// Título do benefício
  @override
  final String title;

  /// Descrição do benefício
  @override
  final String description;

  /// URL da imagem/logo do benefício (opcional)
  @override
  final String? logoUrl;

  /// Código do benefício (para uso/resgate)
  @override
  final String code;

  /// Status atual do benefício
  @override
  final BenefitStatus status;

  /// Data de expiração do benefício
  @override
  final DateTime expirationDate;

  /// Data em que o benefício foi resgatado
  @override
  final DateTime redeemedAt;

  /// Data em que o benefício foi utilizado
  @override
  final DateTime? usedAt;

  /// Data de criação do registro
  @override
  final DateTime createdAt;

  /// Data da última atualização
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'RedeemedBenefit(id: $id, userId: $userId, benefitId: $benefitId, title: $title, description: $description, logoUrl: $logoUrl, code: $code, status: $status, expirationDate: $expirationDate, redeemedAt: $redeemedAt, usedAt: $usedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedeemedBenefitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.benefitId, benefitId) ||
                other.benefitId == benefitId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.redeemedAt, redeemedAt) ||
                other.redeemedAt == redeemedAt) &&
            (identical(other.usedAt, usedAt) || other.usedAt == usedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      benefitId,
      title,
      description,
      logoUrl,
      code,
      status,
      expirationDate,
      redeemedAt,
      usedAt,
      createdAt,
      updatedAt);

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

abstract class _RedeemedBenefit extends RedeemedBenefit {
  const factory _RedeemedBenefit(
      {required final String id,
      required final String userId,
      required final String benefitId,
      required final String title,
      required final String description,
      final String? logoUrl,
      required final String code,
      required final BenefitStatus status,
      required final DateTime expirationDate,
      required final DateTime redeemedAt,
      final DateTime? usedAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$RedeemedBenefitImpl;
  const _RedeemedBenefit._() : super._();

  factory _RedeemedBenefit.fromJson(Map<String, dynamic> json) =
      _$RedeemedBenefitImpl.fromJson;

  /// ID único do benefício resgatado
  @override
  String get id;

  /// ID do usuário que resgatou
  @override
  String get userId;

  /// ID do benefício original
  @override
  String get benefitId;

  /// Título do benefício
  @override
  String get title;

  /// Descrição do benefício
  @override
  String get description;

  /// URL da imagem/logo do benefício (opcional)
  @override
  String? get logoUrl;

  /// Código do benefício (para uso/resgate)
  @override
  String get code;

  /// Status atual do benefício
  @override
  BenefitStatus get status;

  /// Data de expiração do benefício
  @override
  DateTime get expirationDate;

  /// Data em que o benefício foi resgatado
  @override
  DateTime get redeemedAt;

  /// Data em que o benefício foi utilizado
  @override
  DateTime? get usedAt;

  /// Data de criação do registro
  @override
  DateTime get createdAt;

  /// Data da última atualização
  @override
  DateTime? get updatedAt;

  /// Create a copy of RedeemedBenefit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedeemedBenefitImplCopyWith<_$RedeemedBenefitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
