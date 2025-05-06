// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/components/app_error_widget.dart';
import 'package:ray_club_app/core/components/app_loading.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/screens/workout_detail_screen.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';
import 'package:ray_club_app/features/workout/widgets/workout_card.dart';
import 'package:ray_club_app/features/workout/widgets/workout_filter_bar.dart';

@RoutePage()
class WorkoutListScreen extends ConsumerWidget {
  const WorkoutListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(workoutViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Treinos', style: AppTypography.headingMedium),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(workoutViewModelProvider.notifier).loadWorkouts();
            },
          ),
        ],
      ),
      body: _buildBody(context, workoutState, ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/workout/new');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutState state, WidgetRef ref) {
    return state.maybeWhen(
      initial: () => const AppLoading(),
      loading: () => const AppLoading(),
      error: (message) => AppErrorWidget(
        message: message,
        onRetry: () => ref.read(workoutViewModelProvider.notifier).loadWorkouts(),
      ),
      orElse: () => _buildContent(context, state, ref),
    );
  }

  Widget _buildContent(BuildContext context, WorkoutState state, WidgetRef ref) {
    final workouts = state.currentWorkouts;
    final viewModel = ref.read(workoutViewModelProvider.notifier);
    
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 64,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino encontrado',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 24),
            if (state.maybeWhen(
              loaded: (_, __, ___, filter) => filter != const WorkoutFilter(),
              selectedWorkout: (_, __, ___, ____, filter) => filter != const WorkoutFilter(),
              orElse: () => false,
            ))
              ElevatedButton(
                onPressed: () => viewModel.resetFilters(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Limpar filtros',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Barra de pesquisa
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Buscar treinos',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: state.maybeWhen(
                      loaded: (_, __, ___, filter) => filter != const WorkoutFilter() ? AppColors.primary : AppColors.textLight,
                      selectedWorkout: (_, __, ___, ____, filter) => filter != const WorkoutFilter() ? AppColors.primary : AppColors.textLight,
                      orElse: () => AppColors.textLight,
                    ),
                  ),
                  onPressed: () {
                    _showFilterBottomSheet(
                      context,
                      state.maybeWhen(
                        loaded: (_, __, categories, filter) => categories,
                        selectedWorkout: (_, __, ___, categories, filter) => categories,
                        orElse: () => [],
                      ),
                      state.maybeWhen(
                        loaded: (_, __, ___, filter) => filter,
                        selectedWorkout: (_, __, ___, ____, filter) => filter,
                        orElse: () => const WorkoutFilter(),
                      ),
                      viewModel,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        
        // Título para categorias
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.category, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Categorias',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Chips de categorias para acesso rápido
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.maybeWhen(
              loaded: (_, __, categories, ___) => categories.length + 1, // +1 para a opção "Todos"
              selectedWorkout: (_, __, ___, categories, ____) => categories.length + 1,
              orElse: () => 1,
            ),
            itemBuilder: (context, index) {
              // Opção "Todos" como primeiro item
              if (index == 0) {
                final isSelected = state.maybeWhen(
                  loaded: (_, __, ___, filter) => filter.category.isEmpty,
                  selectedWorkout: (_, __, ___, ____, filter) => filter.category.isEmpty,
                  orElse: () => true,
                );
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: const Text('Todos'),
                    labelStyle: AppTypography.bodySmall.copyWith(
                      color: isSelected ? AppColors.white : AppColors.textLight,
                    ),
                    backgroundColor: AppColors.backgroundLight,
                    selectedColor: AppColors.primary,
                    onSelected: (selected) {
                      viewModel.filterByCategory('');
                    },
                  ),
                );
              }
              
              // Categorias
              final categoryIndex = index - 1;
              final categories = state.maybeWhen(
                loaded: (_, __, categories, ___) => categories,
                selectedWorkout: (_, __, ___, categories, ____) => categories,
                orElse: () => <String>[],
              );
              
              if (categoryIndex < categories.length) {
                final category = categories[categoryIndex];
                final isSelected = state.maybeWhen(
                  loaded: (_, __, ___, filter) => filter.category.toLowerCase() == category.toLowerCase(),
                  selectedWorkout: (_, __, ___, ____, filter) => filter.category.toLowerCase() == category.toLowerCase(),
                  orElse: () => false,
                );
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(category),
                    labelStyle: AppTypography.bodySmall.copyWith(
                      color: isSelected ? AppColors.white : AppColors.textLight,
                    ),
                    backgroundColor: AppColors.backgroundLight,
                    selectedColor: AppColors.primary,
                    onSelected: (selected) {
                      viewModel.filterByCategory(category);
                    },
                  ),
                );
              }
              
              return const SizedBox.shrink();
            },
          ),
        ),
        
        // Título para duração
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.timer, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Duração',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Chips de duração para acesso rápido
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6, // Todos, 15min, 30min, 45min, 60min, 90+min
            itemBuilder: (context, index) {
              // Opções de duração em minutos
              final durationOptions = [0, 15, 30, 45, 60, 90];
              final duration = durationOptions[index];
              
              final isSelected = state.maybeWhen(
                loaded: (_, __, ___, filter) => filter.maxDuration == duration,
                selectedWorkout: (_, __, ___, ____, filter) => filter.maxDuration == duration,
                orElse: () => duration == 0, // Por padrão, "Todos" está selecionado
              );
              
              final label = duration == 0 
                ? 'Todos' 
                : duration == 90 
                  ? '90+ min' 
                  : '$duration min';
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(label),
                  labelStyle: AppTypography.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textLight,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.backgroundLight,
                  selectedColor: AppColors.primary,
                  onSelected: (selected) {
                    viewModel.filterByDuration(duration);
                  },
                ),
              );
            },
          ),
        ),
        
        // Indicador de filtros ativos
        if (state.maybeWhen(
          loaded: (_, __, ___, filter) => filter != const WorkoutFilter(),
          selectedWorkout: (_, __, ___, ____, filter) => filter != const WorkoutFilter(),
          orElse: () => false,
        ))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Filtros ativos',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    viewModel.resetFilters();
                  },
                  child: Text(
                    'Limpar todos',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return WorkoutCard(
                  workout: workout,
                  onTap: () => _navigateToDetail(context, workout, ref),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _formatDurationFilter(WorkoutFilter filter) {
    if (filter.maxDuration == 15) {
      return 'Até 15 min';
    } else if (filter.maxDuration == 30) {
      return '16-30 min';
    } else if (filter.maxDuration == 45) {
      return '31-45 min';
    } else if (filter.maxDuration == 60) {
      return '46-60 min';
    } else if (filter.maxDuration == 999) {
      return 'Mais de 60 min';
    }
    return 'Filtro de duração';
  }

  void _showFilterBottomSheet(
    BuildContext context,
    List<String> categories,
    WorkoutFilter currentFilter,
    WorkoutViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              WorkoutFilterBar(
                categories: categories,
                currentFilter: currentFilter,
                onCategorySelected: (category) {
                  viewModel.filterByCategory(category);
                  Navigator.pop(context);
                },
                onDurationSelected: (minutes) {
                  viewModel.filterByDuration(minutes);
                  Navigator.pop(context);
                },
                onDifficultySelected: (difficulty) {
                  viewModel.filterByDifficulty(difficulty);
                  Navigator.pop(context);
                },
                onResetFilters: () {
                  viewModel.resetFilters();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, Workout workout, WidgetRef ref) {
    ref.read(workoutViewModelProvider.notifier).selectWorkout(workout.id);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workoutId: workout.id),
      ),
    ).then((_) {
      // Quando voltar da tela de detalhes, limpar a seleção
      ref.read(workoutViewModelProvider.notifier).clearSelection();
    });
  }
} 
