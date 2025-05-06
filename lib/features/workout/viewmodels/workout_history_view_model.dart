// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';

part 'workout_history_view_model.freezed.dart';

/// Estado para o gerenciamento do histórico de treinos
@freezed
abstract class WorkoutHistoryState with _$WorkoutHistoryState {
  /// Estado de carregamento
  const factory WorkoutHistoryState.loading() = _Loading;
  
  /// Estado quando não há registros
  const factory WorkoutHistoryState.empty() = _Empty;
  
  /// Estado com registros carregados
  const factory WorkoutHistoryState.loaded({
    required List<WorkoutRecord> allRecords,
    DateTime? selectedDate,
    List<WorkoutRecord>? selectedDateRecords,
  }) = _Loaded;
  
  /// Estado de erro
  const factory WorkoutHistoryState.error(String message) = _Error;
}

/// ViewModel para gerenciar o histórico de treinos
class WorkoutHistoryViewModel extends StateNotifier<WorkoutHistoryState> {
  final WorkoutRecordRepository _repository;
  
  WorkoutHistoryViewModel(this._repository) : super(const WorkoutHistoryState.loading()) {
    loadWorkoutHistory();
  }
  
  /// Carrega o histórico de treinos do usuário atual
  Future<void> loadWorkoutHistory() async {
    try {
      state = const WorkoutHistoryState.loading();
      
      final records = await _repository.getUserWorkoutRecords();
      
      if (records.isEmpty) {
        state = const WorkoutHistoryState.empty();
      } else {
        state = WorkoutHistoryState.loaded(
          allRecords: records,
          selectedDate: null,
          selectedDateRecords: null,
        );
      }
    } catch (e) {
      state = WorkoutHistoryState.error('Erro ao carregar histórico: ${e.toString()}');
    }
  }
  
  /// Obtém os dias que têm treinos registrados
  Map<DateTime, List<WorkoutRecord>> getWorkoutsByDay() {
    final currentState = state;
    if (currentState is! _Loaded) {
      return {};
    }
    
    final Map<DateTime, List<WorkoutRecord>> workoutsByDay = {};
    for (final record in currentState.allRecords) {
      // Normalizar a data (remover hora/minuto/segundo)
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      workoutsByDay.putIfAbsent(date, () => []).add(record);
    }
    
    return workoutsByDay;
  }
  
  /// Seleciona uma data para mostrar os treinos
  void selectDate(DateTime? date) {
    final currentState = state;
    if (currentState is! _Loaded) {
      return;
    }
    
    if (date == null) {
      state = WorkoutHistoryState.loaded(
        allRecords: currentState.allRecords,
        selectedDate: null,
        selectedDateRecords: null,
      );
      return;
    }
    
    // Normalizar a data (remover hora/minuto/segundo)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Filtrar os registros da data selecionada
    final dateRecords = currentState.allRecords.where((record) {
      final recordDate = DateTime(
        record.date.year, 
        record.date.month, 
        record.date.day,
      );
      return recordDate.isAtSameMomentAs(normalizedDate);
    }).toList();
    
    state = WorkoutHistoryState.loaded(
      allRecords: currentState.allRecords,
      selectedDate: normalizedDate,
      selectedDateRecords: dateRecords,
    );
  }
  
  /// Limpa a seleção de data
  void clearSelectedDate() {
    final currentState = state;
    if (currentState is! _Loaded) {
      return;
    }
    
    state = WorkoutHistoryState.loaded(
      allRecords: currentState.allRecords,
      selectedDate: null,
      selectedDateRecords: null,
    );
  }
}

/// Provider para o ViewModel do histórico de treinos
final workoutHistoryViewModelProvider = StateNotifierProvider<WorkoutHistoryViewModel, WorkoutHistoryState>((ref) {
  final repository = ref.watch(workoutRecordRepositoryProvider);
  return WorkoutHistoryViewModel(repository);
}); 