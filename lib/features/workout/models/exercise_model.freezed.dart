// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  return _Exercise.fromJson(json);
}

/// @nodoc
mixin _$Exercise {
  /// Nome do exercício
  String get name => throw _privateConstructorUsedError;

  /// Descrição do exercício
  String? get description => throw _privateConstructorUsedError;

  /// Instruções detalhadas para execução
  String get instructions => throw _privateConstructorUsedError;

  /// Número de séries
  int get sets => throw _privateConstructorUsedError;

  /// Número de repetições por série
  int get repetitions => throw _privateConstructorUsedError;

  /// Tempo de duração em segundos (para exercícios por tempo)
  int get duration => throw _privateConstructorUsedError;

  /// Tempo de descanso em segundos entre séries
  int get restSeconds => throw _privateConstructorUsedError;

  /// URL da imagem demonstrativa (opcional)
  String? get imageUrl => throw _privateConstructorUsedError;

  /// URL do vídeo demonstrativo (opcional)
  String? get videoUrl => throw _privateConstructorUsedError;

  /// Músculos trabalhados neste exercício
  List<String> get targetMuscles => throw _privateConstructorUsedError;

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseCopyWith<Exercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) then) =
      _$ExerciseCopyWithImpl<$Res, Exercise>;
  @useResult
  $Res call(
      {String name,
      String? description,
      String instructions,
      int sets,
      int repetitions,
      int duration,
      int restSeconds,
      String? imageUrl,
      String? videoUrl,
      List<String> targetMuscles});
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res, $Val extends Exercise>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? instructions = null,
    Object? sets = null,
    Object? repetitions = null,
    Object? duration = null,
    Object? restSeconds = null,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? targetMuscles = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      targetMuscles: null == targetMuscles
          ? _value.targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseImplCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$$ExerciseImplCopyWith(
          _$ExerciseImpl value, $Res Function(_$ExerciseImpl) then) =
      __$$ExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? description,
      String instructions,
      int sets,
      int repetitions,
      int duration,
      int restSeconds,
      String? imageUrl,
      String? videoUrl,
      List<String> targetMuscles});
}

/// @nodoc
class __$$ExerciseImplCopyWithImpl<$Res>
    extends _$ExerciseCopyWithImpl<$Res, _$ExerciseImpl>
    implements _$$ExerciseImplCopyWith<$Res> {
  __$$ExerciseImplCopyWithImpl(
      _$ExerciseImpl _value, $Res Function(_$ExerciseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? instructions = null,
    Object? sets = null,
    Object? repetitions = null,
    Object? duration = null,
    Object? restSeconds = null,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? targetMuscles = null,
  }) {
    return _then(_$ExerciseImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      targetMuscles: null == targetMuscles
          ? _value._targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseImpl implements _Exercise {
  const _$ExerciseImpl(
      {required this.name,
      this.description,
      this.instructions = "",
      this.sets = 3,
      this.repetitions = 12,
      this.duration = 0,
      this.restSeconds = 60,
      this.imageUrl,
      this.videoUrl,
      final List<String> targetMuscles = const []})
      : _targetMuscles = targetMuscles;

  factory _$ExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseImplFromJson(json);

  /// Nome do exercício
  @override
  final String name;

  /// Descrição do exercício
  @override
  final String? description;

  /// Instruções detalhadas para execução
  @override
  @JsonKey()
  final String instructions;

  /// Número de séries
  @override
  @JsonKey()
  final int sets;

  /// Número de repetições por série
  @override
  @JsonKey()
  final int repetitions;

  /// Tempo de duração em segundos (para exercícios por tempo)
  @override
  @JsonKey()
  final int duration;

  /// Tempo de descanso em segundos entre séries
  @override
  @JsonKey()
  final int restSeconds;

  /// URL da imagem demonstrativa (opcional)
  @override
  final String? imageUrl;

  /// URL do vídeo demonstrativo (opcional)
  @override
  final String? videoUrl;

  /// Músculos trabalhados neste exercício
  final List<String> _targetMuscles;

  /// Músculos trabalhados neste exercício
  @override
  @JsonKey()
  List<String> get targetMuscles {
    if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetMuscles);
  }

  @override
  String toString() {
    return 'Exercise(name: $name, description: $description, instructions: $instructions, sets: $sets, repetitions: $repetitions, duration: $duration, restSeconds: $restSeconds, imageUrl: $imageUrl, videoUrl: $videoUrl, targetMuscles: $targetMuscles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            const DeepCollectionEquality()
                .equals(other._targetMuscles, _targetMuscles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      instructions,
      sets,
      repetitions,
      duration,
      restSeconds,
      imageUrl,
      videoUrl,
      const DeepCollectionEquality().hash(_targetMuscles));

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      __$$ExerciseImplCopyWithImpl<_$ExerciseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseImplToJson(
      this,
    );
  }
}

abstract class _Exercise implements Exercise {
  const factory _Exercise(
      {required final String name,
      final String? description,
      final String instructions,
      final int sets,
      final int repetitions,
      final int duration,
      final int restSeconds,
      final String? imageUrl,
      final String? videoUrl,
      final List<String> targetMuscles}) = _$ExerciseImpl;

  factory _Exercise.fromJson(Map<String, dynamic> json) =
      _$ExerciseImpl.fromJson;

  /// Nome do exercício
  @override
  String get name;

  /// Descrição do exercício
  @override
  String? get description;

  /// Instruções detalhadas para execução
  @override
  String get instructions;

  /// Número de séries
  @override
  int get sets;

  /// Número de repetições por série
  @override
  int get repetitions;

  /// Tempo de duração em segundos (para exercícios por tempo)
  @override
  int get duration;

  /// Tempo de descanso em segundos entre séries
  @override
  int get restSeconds;

  /// URL da imagem demonstrativa (opcional)
  @override
  String? get imageUrl;

  /// URL do vídeo demonstrativo (opcional)
  @override
  String? get videoUrl;

  /// Músculos trabalhados neste exercício
  @override
  List<String> get targetMuscles;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
