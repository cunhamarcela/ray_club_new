// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/bottom_navigation_bar.dart';
import '../models/workout_category.dart';
import '../models/workout_model.dart';
import '../viewmodels/workout_view_model.dart';
import '../viewmodels/workout_categories_view_model.dart';

@RoutePage()
class WorkoutCategoriesScreen extends ConsumerWidget {
  const WorkoutCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(workoutCategoriesViewModelProvider);
    final workoutState = ref.watch(workoutViewModelProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: categoriesState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : categoriesState.errorMessage != null
                ? Center(child: Text('Erro: ${categoriesState.errorMessage}'))
                : _buildCategoriesContent(context, categoriesState.categories, ref),
      ),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildCategoriesContent(BuildContext context, List<WorkoutCategory> categories, WidgetRef ref) {
    final workoutViewModel = ref.read(workoutViewModelProvider.notifier);
    final workoutState = ref.watch(workoutViewModelProvider);
    
    final filter = workoutState.maybeWhen(
      loaded: (_, __, ___, filter) => filter,
      selectedWorkout: (_, __, ___, ____, filter) => filter,
      orElse: () => const WorkoutFilter(),
    );

    // Obter treinos filtrados
    final filteredWorkouts = workoutState.maybeWhen(
      loaded: (_, filteredWorkouts, ___, ____) => filteredWorkouts,
      selectedWorkout: (_, __, filteredWorkouts, ____, _____) => filteredWorkouts,
      orElse: () => <Workout>[],
    );
    
    // Verificar se existem filtros ativos
    final hasActiveFilter = filter != const WorkoutFilter();
    
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          sliver: SliverToBoxAdapter(
            child: _buildSearchBar(context),
          ),
        ),
        
        // Se não houver filtros ativos, mostrar o treino em destaque
        if (!hasActiveFilter)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: _buildFeaturedWorkout(context),
            ),
          ),
        
        // Filtros de Duração
        SliverPadding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Icon(Icons.timer, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Filtrar por Duração',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6, // Todos, 15min, 30min, 45min, 60min, 90+min
                itemBuilder: (context, index) {
                  // Opções de duração em minutos
                  final durationOptions = [0, 15, 30, 45, 60, 90];
                  final duration = durationOptions[index];
                  
                  final isSelected = filter.maxDuration == duration;
                  
                  final label = duration == 0 
                    ? 'Todos' 
                    : duration == 90 
                      ? '90+ min' 
                      : '$duration min';
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(label),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF666666),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : const Color(0xFFEEEEEE),
                        ),
                      ),
                      onSelected: (selected) {
                        workoutViewModel.filterByDuration(duration);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Mostrar resultados de filtro, se houver filtros ativos
        if (hasActiveFilter && filteredWorkouts.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        filter.category.isNotEmpty ? _getCategoryIcon(filter.category) : Icons.filter_list,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filter.category.isNotEmpty
                            ? 'Treinos de ${filter.category}'
                            : filter.maxDuration > 0
                                ? _formatDurationFilter(filter)
                                : 'Treinos Filtrados',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          workoutViewModel.resetFilters();
                        },
                        child: const Text(
                          'Limpar',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = filteredWorkouts[index];
                        return GestureDetector(
                          onTap: () {
                            // Navegar para o detalhe do treino
                            workoutViewModel.selectWorkout(workout.id);
                            context.pushRoute(WorkoutDetailRoute(workoutId: workout.id));
                          },
                          child: Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: workout.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(workout.imageUrl!),
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.3),
                                        BlendMode.darken,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                // Gradiente para melhorar legibilidade
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Conteúdo
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(workout.type),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          workout.type,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        workout.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.timer,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${workout.durationMinutes} min',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.fitness_center,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            workout.difficulty,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
        // Mostrar mensagem de nenhum resultado encontrado
        if (hasActiveFilter && filteredWorkouts.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: Color(0xFFCCCCCC),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum treino encontrado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tente outros filtros ou categorias',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF666666).withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        workoutViewModel.resetFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Limpar filtros',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Título para categorias se não houver filtros ou se os filtros não retornarem resultados
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          sliver: SliverToBoxAdapter(
            child: const Text(
              'Categorias de Treino',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCategoryCard(context, categories[index], workoutViewModel),
              childCount: categories.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Workouts',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      actions: [
        Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF333333)),
              onPressed: () {
                // Navegar para o histórico de treinos
                context.pushRoute(const WorkoutHistoryRoute());
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar treinos',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF888888)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFeaturedWorkout(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradiente para melhorar legibilidade do texto
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Destaque',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Treino Full Body',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '30 min • Intensidade média',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Navegar para o treino em destaque
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Iniciar Treino'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, WorkoutCategory category, WorkoutViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        // Em vez de navegar, aplicar o filtro de categoria
        viewModel.filterByCategory(category.name);
        
        // Opcional: mostrar um feedback visual de que o filtro foi aplicado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filtrando treinos de ${category.name}'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(category.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradiente para melhorar legibilidade
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _getCategoryColor(category.name).withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Ícone simplificado
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(category.name),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            
            // Informações da categoria
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.workoutsCount} treinos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'cardio':
        return Colors.red;
      case 'força':
        return Colors.blue[800]!;
      case 'yoga':
        return Colors.purple;
      case 'pilates':
        return Colors.teal;
      case 'hiit':
        return Colors.orange;
      case 'alongamento':
        return Colors.green;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'força':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'pilates':
        return Icons.accessibility_new;
      case 'hiit':
        return Icons.flash_on;
      case 'alongamento':
        return Icons.straighten;
      default:
        return Icons.fitness_center;
    }
  }

  String _formatDurationFilter(WorkoutFilter filter) {
    if (filter.maxDuration == 15) {
      return 'Treinos de até 15 min';
    } else if (filter.maxDuration == 30) {
      return 'Treinos de 16-30 min';
    } else if (filter.maxDuration == 45) {
      return 'Treinos de 31-45 min';
    } else if (filter.maxDuration == 60) {
      return 'Treinos de 46-60 min';
    } else if (filter.maxDuration == 90) {
      return 'Treinos de mais de 60 min';
    }
    return 'Treinos filtrados';
  }
} 