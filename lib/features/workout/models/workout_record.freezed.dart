// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutRecord _$WorkoutRecordFromJson(Map<String, dynamic> json) {
  return _WorkoutRecord.fromJson(json);
}

/// @nodoc
mixin _$WorkoutRecord {
  /// Identificador único do registro
  String get id => throw _privateConstructorUsedError;

  /// Identificador do usuário
  String get userId => throw _privateConstructorUsedError;

  /// Identificador do treino (pode ser null para treinos personalizados)
  String? get workoutId => throw _privateConstructorUsedError;

  /// Nome do treino realizado
  String get workoutName => throw _privateConstructorUsedError;

  /// Tipo/categoria do treino
  String get workoutType => throw _privateConstructorUsedError;

  /// Data e hora do treino
  DateTime get date => throw _privateConstructorUsedError;

  /// Duração em minutos
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Se o treino foi completado integralmente
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Notas ou observações opcionais sobre o treino
  String? get notes => throw _privateConstructorUsedError;

  /// Data de criação do registro
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WorkoutRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutRecordCopyWith<WorkoutRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutRecordCopyWith<$Res> {
  factory $WorkoutRecordCopyWith(
          WorkoutRecord value, $Res Function(WorkoutRecord) then) =
      _$WorkoutRecordCopyWithImpl<$Res, WorkoutRecord>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? workoutId,
      String workoutName,
      String workoutType,
      DateTime date,
      int durationMinutes,
      bool isCompleted,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$WorkoutRecordCopyWithImpl<$Res, $Val extends WorkoutRecord>
    implements $WorkoutRecordCopyWith<$Res> {
  _$WorkoutRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? workoutId = freezed,
    Object? workoutName = null,
    Object? workoutType = null,
    Object? date = null,
    Object? durationMinutes = null,
    Object? isCompleted = null,
    Object? notes = freezed,
    Object? createdAt = null,
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
      workoutId: freezed == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      workoutType: null == workoutType
          ? _value.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutRecordImplCopyWith<$Res>
    implements $WorkoutRecordCopyWith<$Res> {
  factory _$$WorkoutRecordImplCopyWith(
          _$WorkoutRecordImpl value, $Res Function(_$WorkoutRecordImpl) then) =
      __$$WorkoutRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? workoutId,
      String workoutName,
      String workoutType,
      DateTime date,
      int durationMinutes,
      bool isCompleted,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$WorkoutRecordImplCopyWithImpl<$Res>
    extends _$WorkoutRecordCopyWithImpl<$Res, _$WorkoutRecordImpl>
    implements _$$WorkoutRecordImplCopyWith<$Res> {
  __$$WorkoutRecordImplCopyWithImpl(
      _$WorkoutRecordImpl _value, $Res Function(_$WorkoutRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? workoutId = freezed,
    Object? workoutName = null,
    Object? workoutType = null,
    Object? date = null,
    Object? durationMinutes = null,
    Object? isCompleted = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$WorkoutRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutId: freezed == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      workoutType: null == workoutType
          ? _value.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutRecordImpl implements _WorkoutRecord {
  const _$WorkoutRecordImpl(
      {required this.id,
      required this.userId,
      this.workoutId,
      required this.workoutName,
      required this.workoutType,
      required this.date,
      required this.durationMinutes,
      this.isCompleted = true,
      this.notes,
      required this.createdAt});

  factory _$WorkoutRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutRecordImplFromJson(json);

  /// Identificador único do registro
  @override
  final String id;

  /// Identificador do usuário
  @override
  final String userId;

  /// Identificador do treino (pode ser null para treinos personalizados)
  @override
  final String? workoutId;

  /// Nome do treino realizado
  @override
  final String workoutName;

  /// Tipo/categoria do treino
  @override
  final String workoutType;

  /// Data e hora do treino
  @override
  final DateTime date;

  /// Duração em minutos
  @override
  final int durationMinutes;

  /// Se o treino foi completado integralmente
  @override
  @JsonKey()
  final bool isCompleted;

  /// Notas ou observações opcionais sobre o treino
  @override
  final String? notes;

  /// Data de criação do registro
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'WorkoutRecord(id: $id, userId: $userId, workoutId: $workoutId, workoutName: $workoutName, workoutType: $workoutType, date: $date, durationMinutes: $durationMinutes, isCompleted: $isCompleted, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.workoutType, workoutType) ||
                other.workoutType == workoutType) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      workoutId,
      workoutName,
      workoutType,
      date,
      durationMinutes,
      isCompleted,
      notes,
      createdAt);

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutRecordImplCopyWith<_$WorkoutRecordImpl> get copyWith =>
      __$$WorkoutRecordImplCopyWithImpl<_$WorkoutRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutRecordImplToJson(
      this,
    );
  }
}

abstract class _WorkoutRecord implements WorkoutRecord {
  const factory _WorkoutRecord(
      {required final String id,
      required final String userId,
      final String? workoutId,
      required final String workoutName,
      required final String workoutType,
      required final DateTime date,
      required final int durationMinutes,
      final bool isCompleted,
      final String? notes,
      required final DateTime createdAt}) = _$WorkoutRecordImpl;

  factory _WorkoutRecord.fromJson(Map<String, dynamic> json) =
      _$WorkoutRecordImpl.fromJson;

  /// Identificador único do registro
  @override
  String get id;

  /// Identificador do usuário
  @override
  String get userId;

  /// Identificador do treino (pode ser null para treinos personalizados)
  @override
  String? get workoutId;

  /// Nome do treino realizado
  @override
  String get workoutName;

  /// Tipo/categoria do treino
  @override
  String get workoutType;

  /// Data e hora do treino
  @override
  DateTime get date;

  /// Duração em minutos
  @override
  int get durationMinutes;

  /// Se o treino foi completado integralmente
  @override
  bool get isCompleted;

  /// Notas ou observações opcionais sobre o treino
  @override
  String? get notes;

  /// Data de criação do registro
  @override
  DateTime get createdAt;

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutRecordImplCopyWith<_$WorkoutRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
