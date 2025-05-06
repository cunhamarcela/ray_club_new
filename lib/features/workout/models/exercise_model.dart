// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_model.freezed.dart';
part 'exercise_model.g.dart';

/// Modelo para representar um exercício específico
@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    /// Nome do exercício
    required String name,
    
    /// Descrição do exercício
    String? description,
    
    /// Instruções detalhadas para execução
    @Default("") String instructions,
    
    /// Número de séries
    @Default(3) int sets,
    
    /// Número de repetições por série
    @Default(12) int repetitions,
    
    /// Tempo de duração em segundos (para exercícios por tempo)
    @Default(0) int duration,
    
    /// Tempo de descanso em segundos entre séries
    @Default(60) int restSeconds,
    
    /// URL da imagem demonstrativa (opcional)
    String? imageUrl,
    
    /// URL do vídeo demonstrativo (opcional)
    String? videoUrl,
    
    /// Músculos trabalhados neste exercício
    @Default([]) List<String> targetMuscles,
  }) = _Exercise;

  /// Cria um Exercise a partir de um mapa JSON
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
} 
