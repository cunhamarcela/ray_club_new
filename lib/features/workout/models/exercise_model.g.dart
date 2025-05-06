// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseImpl _$$ExerciseImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      instructions: json['instructions'] as String? ?? "",
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 12,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 60,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      targetMuscles: (json['targetMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ExerciseImplToJson(_$ExerciseImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      'instructions': instance.instructions,
      'sets': instance.sets,
      'repetitions': instance.repetitions,
      'duration': instance.duration,
      'restSeconds': instance.restSeconds,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.videoUrl case final value?) 'videoUrl': value,
      'targetMuscles': instance.targetMuscles,
    };
