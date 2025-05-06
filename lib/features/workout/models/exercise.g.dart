// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      detail: json['detail'] as String,
      imageUrl: json['imageUrl'] as String,
      restTime: (json['restTime'] as num?)?.toInt(),
      instructions: json['instructions'] as String?,
      targetMuscles: (json['targetMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      equipment: (json['equipment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      videoUrl: json['videoUrl'] as String?,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'detail': instance.detail,
      'imageUrl': instance.imageUrl,
      if (instance.restTime case final value?) 'restTime': value,
      if (instance.instructions case final value?) 'instructions': value,
      if (instance.targetMuscles case final value?) 'targetMuscles': value,
      if (instance.equipment case final value?) 'equipment': value,
      if (instance.videoUrl case final value?) 'videoUrl': value,
    };
