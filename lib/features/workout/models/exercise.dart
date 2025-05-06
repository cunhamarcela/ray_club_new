// Package imports:
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

/// Modelo que representa um exercício dentro de um treino
@JsonSerializable()
class Exercise extends Equatable {
  /// Identificador único do exercício
  final String id;
  
  /// Nome do exercício
  final String name;
  
  /// Detalhes do exercício (séries, repetições, etc)
  final String detail;
  
  /// URL da imagem ilustrativa do exercício
  final String imageUrl;
  
  /// Tempo de descanso em segundos
  final int? restTime;
  
  /// Instruções para realização do exercício
  final String? instructions;
  
  /// Músculos trabalhados neste exercício
  final List<String>? targetMuscles;
  
  /// Equipamentos necessários para este exercício
  final List<String>? equipment;
  
  /// URL do vídeo demonstrativo do exercício (opcional)
  final String? videoUrl;

  /// Construtor
  const Exercise({
    required this.id,
    required this.name,
    required this.detail,
    required this.imageUrl,
    this.restTime,
    this.instructions,
    this.targetMuscles,
    this.equipment,
    this.videoUrl,
  });

  /// Cria um Exercise a partir de um Map JSON
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  /// Converte o Exercise para um Map JSON
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  @override
  List<Object?> get props => [
    id, 
    name, 
    detail, 
    imageUrl, 
    restTime, 
    instructions, 
    targetMuscles, 
    equipment, 
    videoUrl
  ];

  /// Cria uma cópia deste Exercise com os campos especificados atualizados
  Exercise copyWith({
    String? id,
    String? name,
    String? detail,
    String? imageUrl,
    int? restTime,
    String? instructions,
    List<String>? targetMuscles,
    List<String>? equipment,
    String? videoUrl,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      imageUrl: imageUrl ?? this.imageUrl,
      restTime: restTime ?? this.restTime,
      instructions: instructions ?? this.instructions,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      equipment: equipment ?? this.equipment,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
} 