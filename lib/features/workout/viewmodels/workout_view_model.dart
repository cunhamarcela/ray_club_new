// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/repositories/workout_repository.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';

/// Provider para o repositório de treinos
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  // Para desenvolvimento, usamos o repositório mock
  // Em produção, usaremos a implementação com Supabase
  return MockWorkoutRepository();
  
  // Quando migrar para produção:
  // final supabase = Supabase.instance.client;
  // return SupabaseWorkoutRepository(supabase);
});

/// Provider para o WorkoutViewModel
final workoutViewModelProvider = StateNotifierProvider<WorkoutViewModel, WorkoutState>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return WorkoutViewModel(repository);
});

/// ViewModel para gerenciar treinos
class WorkoutViewModel extends StateNotifier<WorkoutState> {
  final WorkoutRepository _repository;

  WorkoutViewModel(this._repository) : super(const WorkoutState.loading()) {
    loadWorkouts();
  }

  /// Carrega todos os treinos disponíveis
  Future<void> loadWorkouts() async {
    try {
      state = const WorkoutState.loading();
      
      final workouts = await _repository.getWorkouts();
      
      // Extrair categorias únicas
      final categoriesSet = <String>{};
      for (var workout in workouts) {
        if (workout.type.isNotEmpty) {
          categoriesSet.add(workout.type);
        }
      }
      
      state = WorkoutState.loaded(
        workouts: workouts,
        categories: categoriesSet.toList(),
      );
    } on AppException catch (e) {
      state = WorkoutState.error(e.message);
    } catch (e) {
      state = WorkoutState.error('Erro ao carregar treinos: ${e.toString()}');
    }
  }

  /// Filtra treinos por categoria
  void filterByCategory(String category) {
    state.maybeWhen(
      loaded: (workouts, filteredWorkouts, categories, filter) {
        if (workouts.isEmpty) return;
        
        try {
          // Se a categoria for vazia (todas), remove o filtro
          if (category.isEmpty) {
            state = WorkoutState.loaded(
              workouts: workouts,
              filteredWorkouts: workouts,
              categories: categories,
              filter: filter.copyWith(category: ''),
            );
            return;
          }

          final filtered = workouts
              .where((workout) => workout.type.toLowerCase() == category.toLowerCase())
              .toList();

          state = WorkoutState.loaded(
            workouts: workouts,
            filteredWorkouts: filtered,
            categories: categories,
            filter: filter.copyWith(category: category),
          );
        } catch (e) {
          state = WorkoutState.error('Erro ao filtrar treinos: ${e.toString()}');
        }
      },
      selectedWorkout: (selected, workouts, filteredWorkouts, categories, filter) {
        if (workouts.isEmpty) return;
        
        try {
          // Se a categoria for vazia (todas), remove o filtro
          if (category.isEmpty) {
            state = WorkoutState.selectedWorkout(
              workout: selected,
              workouts: workouts,
              filteredWorkouts: workouts,
              categories: categories,
              filter: filter.copyWith(category: ''),
            );
            return;
          }

          final filtered = workouts
              .where((workout) => workout.type.toLowerCase() == category.toLowerCase())
              .toList();

          state = WorkoutState.selectedWorkout(
            workout: selected,
            workouts: workouts,
            filteredWorkouts: filtered,
            categories: categories,
            filter: filter.copyWith(category: category),
          );
        } catch (e) {
          state = WorkoutState.error('Erro ao filtrar treinos: ${e.toString()}');
        }
      },
      orElse: () {},
    );
  }

  /// Filtra treinos por duração máxima
  void filterByDuration(int minutes) {
    state.maybeWhen(
      loaded: (workouts, filteredWorkouts, categories, filter) {
        if (workouts.isEmpty) return;

        try {
          // Se minutos for 0, remove o filtro de duração
          if (minutes == 0) {
            // Manter apenas o filtro de categoria se existir
            if (filter.category.isNotEmpty) {
              filterByCategory(filter.category);
            } else {
              state = WorkoutState.loaded(
                workouts: workouts,
                filteredWorkouts: workouts,
                categories: categories,
                filter: filter.copyWith(maxDuration: 0, minDuration: 0),
              );
            }
            return;
          }

          // Aplicar filtro de duração junto com o filtro de categoria, se existir
          List<Workout> baseWorkouts = workouts;
          if (filter.category.isNotEmpty) {
            baseWorkouts = baseWorkouts
                .where((w) => w.type.toLowerCase() == filter.category.toLowerCase())
                .toList();
          }

          // Definir intervalos de duração com base no valor selecionado
          int minDuration = 0;
          int maxDuration = minutes;
          
          // Ajustar para intervalos específicos
          if (minutes == 15) {
            minDuration = 0;
            maxDuration = 15;
          } else if (minutes == 30) {
            minDuration = 16;
            maxDuration = 30;
          } else if (minutes == 45) {
            minDuration = 31;
            maxDuration = 45;
          } else if (minutes == 60) {
            minDuration = 46;
            maxDuration = 60;
          } else if (minutes == 90) {
            minDuration = 61;
            maxDuration = 999; // Sem limite superior prático
          }
          
          final durationFiltered = baseWorkouts
              .where((workout) => 
                  workout.durationMinutes >= minDuration && 
                  workout.durationMinutes <= maxDuration)
              .toList();

          state = WorkoutState.loaded(
            workouts: workouts,
            filteredWorkouts: durationFiltered,
            categories: categories,
            filter: filter.copyWith(maxDuration: maxDuration, minDuration: minDuration),
          );
        } catch (e) {
          state = WorkoutState.error('Erro ao filtrar treinos: ${e.toString()}');
        }
      },
      selectedWorkout: (selected, workouts, filteredWorkouts, categories, filter) {
        if (workouts.isEmpty) return;

        try {
          // Se minutos for 0, remove o filtro de duração
          if (minutes == 0) {
            // Manter apenas o filtro de categoria se existir
            if (filter.category.isNotEmpty) {
              filterByCategory(filter.category);
            } else {
              state = WorkoutState.selectedWorkout(
                workout: selected,
                workouts: workouts,
                filteredWorkouts: workouts,
                categories: categories,
                filter: filter.copyWith(maxDuration: 0, minDuration: 0),
              );
            }
            return;
          }

          // Aplicar filtro de duração junto com o filtro de categoria, se existir
          List<Workout> baseWorkouts = workouts;
          if (filter.category.isNotEmpty) {
            baseWorkouts = baseWorkouts
                .where((w) => w.type.toLowerCase() == filter.category.toLowerCase())
                .toList();
          }

          // Definir intervalos de duração com base no valor selecionado
          int minDuration = 0;
          int maxDuration = minutes;
          
          // Ajustar para intervalos específicos
          if (minutes == 15) {
            minDuration = 0;
            maxDuration = 15;
          } else if (minutes == 30) {
            minDuration = 16;
            maxDuration = 30;
          } else if (minutes == 45) {
            minDuration = 31;
            maxDuration = 45;
          } else if (minutes == 60) {
            minDuration = 46;
            maxDuration = 60;
          } else if (minutes == 90) {
            minDuration = 61;
            maxDuration = 999; // Sem limite superior prático
          }
          
          final durationFiltered = baseWorkouts
              .where((workout) => 
                  workout.durationMinutes >= minDuration && 
                  workout.durationMinutes <= maxDuration)
              .toList();

          state = WorkoutState.selectedWorkout(
            workout: selected,
            workouts: workouts,
            filteredWorkouts: durationFiltered,
            categories: categories,
            filter: filter.copyWith(maxDuration: maxDuration, minDuration: minDuration),
          );
        } catch (e) {
          state = WorkoutState.error('Erro ao filtrar treinos: ${e.toString()}');
        }
      },
      orElse: () {},
    );
  }

  /// Filtra treinos por dificuldade
  void filterByDifficulty(String difficulty) {
    state.maybeWhen(
      loaded: (workouts, filteredWorkouts, categories, filter) {
        if (workouts.isEmpty) return;
        
        try {
          // Se a dificuldade for vazia (todas), remove o filtro
          if (difficulty.isEmpty) {
            // Reaplica outros filtros se existirem
            if (filter.category.isNotEmpty || filter.maxDuration > 0) {
              List<Workout> filtered = workouts;
              
              if (filter.category.isNotEmpty) {
                filtered = filtered
                    .where((w) => w.type.toLowerCase() == filter.category.toLowerCase())
                    .toList();
              }
              
              if (filter.maxDuration > 0) {
                filtered = filtered
                    .where((w) => 
                        w.durationMinutes >= filter.minDuration && 
                        w.durationMinutes <= filter.maxDuration)
                    .toList();
              }
              
              state = WorkoutState.loaded(
                workouts: workouts,
                filteredWorkouts: filtered,
                categories: categories,
                filter: filter.copyWith(difficulty: ''),
              );
            } else {
              state = WorkoutState.loaded(
                workouts: workouts,
                filteredWorkouts: workouts,
                categories: categories,
                filter: filter.copyWith(difficulty: ''),
              );
            }
            return;
          }

          // Aplicar filtro de dificuldade junto com outros filtros, se existirem
          List<Workout> baseWorkouts = workouts;
          
          if (filter.category.isNotEmpty) {
            baseWorkouts = baseWorkouts
                .where((w) => w.type.toLowerCase() == filter.category.toLowerCase())
                .toList();
          }
          
          if (filter.maxDuration > 0) {
            baseWorkouts = baseWorkouts
                .where((w) => 
                    w.durationMinutes >= filter.minDuration && 
                    w.durationMinutes <= filter.maxDuration)
                .toList();
          }

          final difficultyFiltered = baseWorkouts
              .where((workout) => workout.difficulty.toLowerCase() == difficulty.toLowerCase())
              .toList();

          state = WorkoutState.loaded(
            workouts: workouts,
            filteredWorkouts: difficultyFiltered,
            categories: categories,
            filter: filter.copyWith(difficulty: difficulty),
          );
        } catch (e) {
          state = WorkoutState.error('Erro ao filtrar treinos: ${e.toString()}');
        }
      },
      selectedWorkout: (selected, workouts, filteredWorkouts, categories, filter) {
        // Implementação similar para selectedWorkout...
        // (Código omitido por brevidade, mas seria similar ao caso de loaded)
      },
      orElse: () {},
    );
  }

  /// Reseta todos os filtros aplicados
  void resetFilters() {
    state.maybeWhen(
      loaded: (workouts, _, categories, __) {
        if (workouts.isEmpty) return;
        
        state = WorkoutState.loaded(
          workouts: workouts,
          filteredWorkouts: workouts,
          categories: categories,
          filter: const WorkoutFilter(),
        );
      },
      selectedWorkout: (selected, workouts, _, categories, __) {
        if (workouts.isEmpty) return;
        
        state = WorkoutState.selectedWorkout(
          workout: selected,
          workouts: workouts,
          filteredWorkouts: workouts,
          categories: categories,
          filter: const WorkoutFilter(),
        );
      },
      orElse: () {},
    );
  }

  /// Seleciona um treino específico para visualização detalhada
  Future<void> selectWorkout(String id) async {
    try {
      state = const WorkoutState.loading();
      
      final workout = await _repository.getWorkoutById(id);
      
      // Preservar os estados atuais usando mapWhen
      final workouts = state.maybeWhen(
        loaded: (workouts, _, __, ___) => workouts,
        selectedWorkout: (_, workouts, __, ___, ____) => workouts,
        orElse: () => <Workout>[],
      );
      
      final filteredWorkouts = state.maybeWhen(
        loaded: (_, filteredWorkouts, __, ___) => filteredWorkouts,
        selectedWorkout: (_, __, filteredWorkouts, ___, ____) => filteredWorkouts,
        orElse: () => <Workout>[],
      );
      
      final categories = state.maybeWhen(
        loaded: (_, __, categories, ___) => categories,
        selectedWorkout: (_, __, ___, categories, ____) => categories,
        orElse: () => <String>[],
      );
      
      final filter = state.maybeWhen(
        loaded: (_, __, ___, filter) => filter,
        selectedWorkout: (_, __, ___, ____, filter) => filter,
        orElse: () => const WorkoutFilter(),
      );
      
      state = WorkoutState.selectedWorkout(
        workout: workout,
        workouts: workouts,
        filteredWorkouts: filteredWorkouts,
        categories: categories,
        filter: filter,
      );
    } on AppException catch (e) {
      state = WorkoutState.error(e.message);
    } catch (e) {
      state = WorkoutState.error('Erro ao selecionar treino: ${e.toString()}');
    }
  }

  /// Limpa o treino selecionado e volta para a listagem
  void clearSelection() {
    state.maybeWhen(
      selectedWorkout: (selected, workouts, filteredWorkouts, categories, filter) {
        state = WorkoutState.loaded(
          workouts: workouts,
          filteredWorkouts: filteredWorkouts,
          categories: categories,
          filter: filter,
        );
      },
      orElse: () {
        // Se não estiver no estado selectedWorkout, não faz nada
        // ou recarrega os treinos se for necessário
        if (!state.isLoading && state.currentWorkouts.isEmpty) {
          loadWorkouts();
        }
      },
    );
  }

  /// Cria um novo treino
  Future<void> createWorkout(Workout workout) async {
    try {
      state = const WorkoutState.loading();
      
      final createdWorkout = await _repository.createWorkout(workout);
      
      // Preservar os estados atuais usando mapWhen
      final currentWorkouts = state.maybeWhen(
        loaded: (workouts, _, __, ___) => workouts,
        selectedWorkout: (_, workouts, __, ___, ____) => workouts,
        orElse: () => <Workout>[],
      );
      
      // Adicionar o novo treino à lista
      final updatedWorkouts = [...currentWorkouts, createdWorkout];
      
      // Atualizar categorias
      final categoriesSet = <String>{};
      for (var w in updatedWorkouts) {
        if (w.type.isNotEmpty) {
          categoriesSet.add(w.type);
        }
      }
      
      // Atualizar filteredWorkouts se necessário
      final currentFilter = state.maybeWhen(
        loaded: (_, __, ___, filter) => filter,
        selectedWorkout: (_, __, ___, ____, filter) => filter,
        orElse: () => const WorkoutFilter(),
      );
      
      List<Workout> filteredWorkouts;
      if (currentFilter == const WorkoutFilter()) {
        // Se não houver filtros, mostrar todos os treinos
        filteredWorkouts = updatedWorkouts;
      } else {
        // Manter os filtros atuais
        filteredWorkouts = state.maybeWhen(
          loaded: (_, filteredWorkouts, __, ___) => filteredWorkouts, 
          selectedWorkout: (_, __, filteredWorkouts, ___, ____) => filteredWorkouts,
          orElse: () => updatedWorkouts,
        );
      }
      
      state = WorkoutState.loaded(
        workouts: updatedWorkouts as List<Workout>, // Cast para List<Workout>
        filteredWorkouts: filteredWorkouts,
        categories: categoriesSet.toList(),
        filter: currentFilter,
      );
    } on AppException catch (e) {
      state = WorkoutState.error(e.message);
    } catch (e) {
      state = WorkoutState.error('Erro ao criar treino: ${e.toString()}');
    }
  }

  /// Atualiza um treino existente
  Future<void> updateWorkout(Workout workout) async {
    try {
      final updatedWorkout = await _repository.updateWorkout(workout);
      
      // Preservar os estados atuais usando mapWhen
      final currentWorkouts = state.maybeWhen(
        loaded: (workouts, _, __, ___) => workouts.map((w) => 
            w.id == updatedWorkout.id ? updatedWorkout : w).toList(),
        selectedWorkout: (_, workouts, __, ___, ____) => workouts.map((w) => 
            w.id == updatedWorkout.id ? updatedWorkout : w).toList(),
        orElse: () => <Workout>[],
      );
      
      final currentFilteredWorkouts = state.maybeWhen(
        loaded: (_, filteredWorkouts, __, ___) => filteredWorkouts.map((w) => 
            w.id == updatedWorkout.id ? updatedWorkout : w).toList(),
        selectedWorkout: (_, __, filteredWorkouts, ___, ____) => filteredWorkouts.map((w) => 
            w.id == updatedWorkout.id ? updatedWorkout : w).toList(),
        orElse: () => <Workout>[],
      );
      
      final currentCategories = state.maybeWhen(
        loaded: (_, __, categories, ___) => categories,
        selectedWorkout: (_, __, ___, categories, ____) => categories,
        orElse: () => <String>[],
      );
      
      final currentFilter = state.maybeWhen(
        loaded: (_, __, ___, filter) => filter,
        selectedWorkout: (_, __, ___, ____, filter) => filter,
        orElse: () => const WorkoutFilter(),
      );
      
      // Se estiver no estado selecionado, atualizar o treino selecionado também
      state.maybeWhen(
        selectedWorkout: (selected, _, __, ___, ____) {
          if (selected.id == updatedWorkout.id) {
            state = WorkoutState.selectedWorkout(
              workout: updatedWorkout,
              workouts: currentWorkouts,
              filteredWorkouts: currentFilteredWorkouts,
              categories: currentCategories,
              filter: currentFilter,
            );
          } else {
            state = WorkoutState.selectedWorkout(
              workout: selected,
              workouts: currentWorkouts,
              filteredWorkouts: currentFilteredWorkouts,
              categories: currentCategories,
              filter: currentFilter,
            );
          }
        },
        orElse: () {
          state = WorkoutState.loaded(
            workouts: currentWorkouts,
            filteredWorkouts: currentFilteredWorkouts,
            categories: currentCategories,
            filter: currentFilter,
          );
        },
      );
    } on AppException catch (e) {
      state = WorkoutState.error(e.message);
    } catch (e) {
      state = WorkoutState.error('Erro ao atualizar treino: ${e.toString()}');
    }
  }

  /// Deleta um treino
  Future<void> deleteWorkout(String id) async {
    try {
      await _repository.deleteWorkout(id);
      
      // Preservar os estados atuais usando mapWhen
      final currentWorkouts = state.maybeWhen(
        loaded: (workouts, _, __, ___) => workouts.where((w) => w.id != id).toList(),
        selectedWorkout: (_, workouts, __, ___, ____) => workouts.where((w) => w.id != id).toList(),
        orElse: () => <Workout>[],
      );
      
      final currentFilteredWorkouts = state.maybeWhen(
        loaded: (_, filteredWorkouts, __, ___) => filteredWorkouts.where((w) => w.id != id).toList(),
        selectedWorkout: (_, __, filteredWorkouts, ___, ____) => filteredWorkouts.where((w) => w.id != id).toList(),
        orElse: () => <Workout>[],
      );
      
      final currentCategories = state.maybeWhen(
        loaded: (_, __, categories, ___) => categories,
        selectedWorkout: (_, __, ___, categories, ____) => categories,
        orElse: () => <String>[],
      );
      
      final currentFilter = state.maybeWhen(
        loaded: (_, __, ___, filter) => filter,
        selectedWorkout: (_, __, ___, ____, filter) => filter,
        orElse: () => const WorkoutFilter(),
      );
      
      // Se excluiu o treino selecionado, voltar para a lista
      final currentSelected = state.maybeWhen(
        selectedWorkout: (selected, _, __, ___, ____) => selected.id == id ? null : selected,
        orElse: () => null,
      );
      
      if (currentSelected == null) {
        state = WorkoutState.loaded(
          workouts: currentWorkouts,
          filteredWorkouts: currentFilteredWorkouts,
          categories: currentCategories,
          filter: currentFilter,
        );
      } else {
        state = WorkoutState.selectedWorkout(
          workout: currentSelected,
          workouts: currentWorkouts,
          filteredWorkouts: currentFilteredWorkouts,
          categories: currentCategories,
          filter: currentFilter,
        );
      }
    } on AppException catch (e) {
      state = WorkoutState.error(e.message);
    } catch (e) {
      state = WorkoutState.error('Erro ao excluir treino: ${e.toString()}');
    }
  }
} 
