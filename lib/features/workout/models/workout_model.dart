// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_section_model.dart';

part 'workout_model.freezed.dart';
part 'workout_model.g.dart';

/// Modelo que representa um treino no aplicativo.
@freezed
class Workout with _$Workout {
  const factory Workout({
    /// Identificador único do treino
    required String id,
    
    /// Título do treino
    required String title,
    
    /// Descrição detalhada do treino
    required String description,
    
    /// URL da imagem do treino (opcional)
    String? imageUrl,
    
    /// Tipo/categoria do treino (ex: "Yoga", "HIIT", "Musculação")
    required String type,
    
    /// Duração do treino em minutos
    required int durationMinutes,
    
    /// Nível de dificuldade (ex: "Iniciante", "Intermediário", "Avançado")
    required String difficulty,
    
    /// Lista de equipamentos necessários
    required List<String> equipment,
    
    /// Lista de seções do treino (aquecimento, principal, etc.)
    @Default([]) List<WorkoutSection> sections,
    
    /// ID do criador do treino
    required String creatorId,
    
    /// Data de criação do treino
    required DateTime createdAt,
    
    /// Data da última atualização (opcional)
    DateTime? updatedAt,
    
    /// Mapa de exercícios por seção (para compatibilidade com testes)
    /// A chave representa o nome da seção (ex: 'warmup', 'main', 'cooldown')
    /// O valor é uma lista de nomes de exercícios
    Map<String, List<String>>? exercises,
  }) = _Workout;

  /// Cria um Workout a partir de um mapa JSON
  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
}

/// Modelo para representar um exercício específico
@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    /// Nome do exercício
    required String name,
    
    /// Descrição do exercício
    String? description,
    
    /// Número de séries
    @Default(3) int sets,
    
    /// Número de repetições por série
    @Default(12) int reps,
    
    /// Tempo de descanso em segundos entre séries
    @Default(60) int restSeconds,
    
    /// URL da imagem demonstrativa (opcional)
    String? imageUrl,
    
    /// URL do vídeo demonstrativo (opcional)
    String? videoUrl,
  }) = _Exercise;

  /// Cria um Exercise a partir de um mapa JSON
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
}

/// Modelo para representar uma seção de exercícios (aquecimento, principal, etc.)
@freezed
class WorkoutSection with _$WorkoutSection {
  const factory WorkoutSection({
    /// Nome da seção
    required String name,
    
    /// Lista de exercícios na seção
    required List<Exercise> exercises,
  }) = _WorkoutSection;

  /// Cria um WorkoutSection a partir de um mapa JSON
  factory WorkoutSection.fromJson(Map<String, dynamic> json) => _$WorkoutSectionFromJson(json);
}

/// Modelo para filtros de treino na interface
@freezed
class WorkoutFilter with _$WorkoutFilter {
  const factory WorkoutFilter({
    /// Categoria selecionada (vazio = todas)
    @Default('') String category,
    
    /// Duração máxima em minutos (0 = sem filtro)
    @Default(0) int maxDuration,
    
    /// Duração mínima em minutos (usado para intervalos de duração)
    @Default(0) int minDuration,
    
    /// Dificuldade selecionada (vazio = todas)
    @Default('') String difficulty,
  }) = _WorkoutFilter;
  
  /// Cria um WorkoutFilter a partir de um mapa JSON
  factory WorkoutFilter.fromJson(Map<String, dynamic> json) => _$WorkoutFilterFromJson(json);
} 
