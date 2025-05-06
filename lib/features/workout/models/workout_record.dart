// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_record.freezed.dart';
part 'workout_record.g.dart';

/// Modelo que representa um registro de treino realizado pelo usuário
@freezed
class WorkoutRecord with _$WorkoutRecord {
  const factory WorkoutRecord({
    /// Identificador único do registro
    required String id,
    
    /// Identificador do usuário
    required String userId,
    
    /// Identificador do treino (pode ser null para treinos personalizados)
    String? workoutId,
    
    /// Nome do treino realizado
    required String workoutName,
    
    /// Tipo/categoria do treino
    required String workoutType,
    
    /// Data e hora do treino
    required DateTime date,
    
    /// Duração em minutos
    required int durationMinutes,
    
    /// Se o treino foi completado integralmente
    @Default(true) bool isCompleted,
    
    /// Notas ou observações opcionais sobre o treino
    String? notes,
    
    /// Data de criação do registro
    required DateTime createdAt,
  }) = _WorkoutRecord;

  /// Cria um WorkoutRecord a partir de um mapa JSON
  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => _$WorkoutRecordFromJson(json);
} 