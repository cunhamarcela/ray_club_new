// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) {
  return _DashboardData.fromJson(json);
}

/// @nodoc
mixin _$DashboardData {
  /// Progresso do usuário
  UserProgress get userProgress => throw _privateConstructorUsedError;

  /// Data da última atualização dos dados
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Desafio atual do usuário (se houver)
  Challenge? get currentChallenge => throw _privateConstructorUsedError;

  /// Progresso do desafio atual (se houver)
  ChallengeProgress? get challengeProgress =>
      throw _privateConstructorUsedError;

  /// Lista de benefícios resgatados
  List<RedeemedBenefit> get redeemedBenefits =>
      throw _privateConstructorUsedError;

  /// Mapa com dados adicionais (consumo de água, metas, etc.)
  Map<String, dynamic> get additionalData => throw _privateConstructorUsedError;

  /// Serializes this DashboardData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardDataCopyWith<DashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardDataCopyWith<$Res> {
  factory $DashboardDataCopyWith(
          DashboardData value, $Res Function(DashboardData) then) =
      _$DashboardDataCopyWithImpl<$Res, DashboardData>;
  @useResult
  $Res call(
      {UserProgress userProgress,
      DateTime lastUpdated,
      Challenge? currentChallenge,
      ChallengeProgress? challengeProgress,
      List<RedeemedBenefit> redeemedBenefits,
      Map<String, dynamic> additionalData});

  $UserProgressCopyWith<$Res> get userProgress;
  $ChallengeCopyWith<$Res>? get currentChallenge;
}

/// @nodoc
class _$DashboardDataCopyWithImpl<$Res, $Val extends DashboardData>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProgress = null,
    Object? lastUpdated = null,
    Object? currentChallenge = freezed,
    Object? challengeProgress = freezed,
    Object? redeemedBenefits = null,
    Object? additionalData = null,
  }) {
    return _then(_value.copyWith(
      userProgress: null == userProgress
          ? _value.userProgress
          : userProgress // ignore: cast_nullable_to_non_nullable
              as UserProgress,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentChallenge: freezed == currentChallenge
          ? _value.currentChallenge
          : currentChallenge // ignore: cast_nullable_to_non_nullable
              as Challenge?,
      challengeProgress: freezed == challengeProgress
          ? _value.challengeProgress
          : challengeProgress // ignore: cast_nullable_to_non_nullable
              as ChallengeProgress?,
      redeemedBenefits: null == redeemedBenefits
          ? _value.redeemedBenefits
          : redeemedBenefits // ignore: cast_nullable_to_non_nullable
              as List<RedeemedBenefit>,
      additionalData: null == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProgressCopyWith<$Res> get userProgress {
    return $UserProgressCopyWith<$Res>(_value.userProgress, (value) {
      return _then(_value.copyWith(userProgress: value) as $Val);
    });
  }

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeCopyWith<$Res>? get currentChallenge {
    if (_value.currentChallenge == null) {
      return null;
    }

    return $ChallengeCopyWith<$Res>(_value.currentChallenge!, (value) {
      return _then(_value.copyWith(currentChallenge: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardDataImplCopyWith<$Res>
    implements $DashboardDataCopyWith<$Res> {
  factory _$$DashboardDataImplCopyWith(
          _$DashboardDataImpl value, $Res Function(_$DashboardDataImpl) then) =
      __$$DashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {UserProgress userProgress,
      DateTime lastUpdated,
      Challenge? currentChallenge,
      ChallengeProgress? challengeProgress,
      List<RedeemedBenefit> redeemedBenefits,
      Map<String, dynamic> additionalData});

  @override
  $UserProgressCopyWith<$Res> get userProgress;
  @override
  $ChallengeCopyWith<$Res>? get currentChallenge;
}

/// @nodoc
class __$$DashboardDataImplCopyWithImpl<$Res>
    extends _$DashboardDataCopyWithImpl<$Res, _$DashboardDataImpl>
    implements _$$DashboardDataImplCopyWith<$Res> {
  __$$DashboardDataImplCopyWithImpl(
      _$DashboardDataImpl _value, $Res Function(_$DashboardDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProgress = null,
    Object? lastUpdated = null,
    Object? currentChallenge = freezed,
    Object? challengeProgress = freezed,
    Object? redeemedBenefits = null,
    Object? additionalData = null,
  }) {
    return _then(_$DashboardDataImpl(
      userProgress: null == userProgress
          ? _value.userProgress
          : userProgress // ignore: cast_nullable_to_non_nullable
              as UserProgress,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentChallenge: freezed == currentChallenge
          ? _value.currentChallenge
          : currentChallenge // ignore: cast_nullable_to_non_nullable
              as Challenge?,
      challengeProgress: freezed == challengeProgress
          ? _value.challengeProgress
          : challengeProgress // ignore: cast_nullable_to_non_nullable
              as ChallengeProgress?,
      redeemedBenefits: null == redeemedBenefits
          ? _value._redeemedBenefits
          : redeemedBenefits // ignore: cast_nullable_to_non_nullable
              as List<RedeemedBenefit>,
      additionalData: null == additionalData
          ? _value._additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardDataImpl implements _DashboardData {
  const _$DashboardDataImpl(
      {required this.userProgress,
      required this.lastUpdated,
      this.currentChallenge,
      this.challengeProgress,
      final List<RedeemedBenefit> redeemedBenefits = const [],
      final Map<String, dynamic> additionalData = const {}})
      : _redeemedBenefits = redeemedBenefits,
        _additionalData = additionalData;

  factory _$DashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardDataImplFromJson(json);

  /// Progresso do usuário
  @override
  final UserProgress userProgress;

  /// Data da última atualização dos dados
  @override
  final DateTime lastUpdated;

  /// Desafio atual do usuário (se houver)
  @override
  final Challenge? currentChallenge;

  /// Progresso do desafio atual (se houver)
  @override
  final ChallengeProgress? challengeProgress;

  /// Lista de benefícios resgatados
  final List<RedeemedBenefit> _redeemedBenefits;

  /// Lista de benefícios resgatados
  @override
  @JsonKey()
  List<RedeemedBenefit> get redeemedBenefits {
    if (_redeemedBenefits is EqualUnmodifiableListView)
      return _redeemedBenefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_redeemedBenefits);
  }

  /// Mapa com dados adicionais (consumo de água, metas, etc.)
  final Map<String, dynamic> _additionalData;

  /// Mapa com dados adicionais (consumo de água, metas, etc.)
  @override
  @JsonKey()
  Map<String, dynamic> get additionalData {
    if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_additionalData);
  }

  @override
  String toString() {
    return 'DashboardData(userProgress: $userProgress, lastUpdated: $lastUpdated, currentChallenge: $currentChallenge, challengeProgress: $challengeProgress, redeemedBenefits: $redeemedBenefits, additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDataImpl &&
            (identical(other.userProgress, userProgress) ||
                other.userProgress == userProgress) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.currentChallenge, currentChallenge) ||
                other.currentChallenge == currentChallenge) &&
            (identical(other.challengeProgress, challengeProgress) ||
                other.challengeProgress == challengeProgress) &&
            const DeepCollectionEquality()
                .equals(other._redeemedBenefits, _redeemedBenefits) &&
            const DeepCollectionEquality()
                .equals(other._additionalData, _additionalData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userProgress,
      lastUpdated,
      currentChallenge,
      challengeProgress,
      const DeepCollectionEquality().hash(_redeemedBenefits),
      const DeepCollectionEquality().hash(_additionalData));

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      __$$DashboardDataImplCopyWithImpl<_$DashboardDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardDataImplToJson(
      this,
    );
  }
}

abstract class _DashboardData implements DashboardData {
  const factory _DashboardData(
      {required final UserProgress userProgress,
      required final DateTime lastUpdated,
      final Challenge? currentChallenge,
      final ChallengeProgress? challengeProgress,
      final List<RedeemedBenefit> redeemedBenefits,
      final Map<String, dynamic> additionalData}) = _$DashboardDataImpl;

  factory _DashboardData.fromJson(Map<String, dynamic> json) =
      _$DashboardDataImpl.fromJson;

  /// Progresso do usuário
  @override
  UserProgress get userProgress;

  /// Data da última atualização dos dados
  @override
  DateTime get lastUpdated;

  /// Desafio atual do usuário (se houver)
  @override
  Challenge? get currentChallenge;

  /// Progresso do desafio atual (se houver)
  @override
  ChallengeProgress? get challengeProgress;

  /// Lista de benefícios resgatados
  @override
  List<RedeemedBenefit> get redeemedBenefits;

  /// Mapa com dados adicionais (consumo de água, metas, etc.)
  @override
  Map<String, dynamic> get additionalData;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
