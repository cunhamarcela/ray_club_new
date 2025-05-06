// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/workout_model.dart';
import '../viewmodels/workout_view_model.dart';

@RoutePage()
class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({
    super.key,
    @PathParam('id') required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(workoutViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: workoutState.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => Center(child: Text('Erro: $message')),
        loaded: (workouts, selectedCategory, _, __) => Center(child: Text('Selecione um treino')),
        selectedWorkout: (workout, _, __, ___, ____) => _buildWorkoutDetail(context, workout),
      ),
    );
  }

  Widget _buildWorkoutDetail(BuildContext context, Workout workout) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, workout),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkoutInfo(context, workout),
                const SizedBox(height: 32),
                _buildWorkoutDescription(context, workout),
                const SizedBox(height: 32),
                _buildExercisesList(context, workout),
                const SizedBox(height: 32),
                _buildActionButtons(context, workout),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Workout workout) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem de fundo
            workout.imageUrl != null
                ? Image.network(
                    workout.imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            
            // Gradiente para melhorar legibilidade
            Container(
              decoration: BoxDecoration(
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
            
            // Informações no AppBar
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      workout.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Título
                  Text(
                    workout.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Informações básicas
                  Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.durationMinutes} min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTotalExerciseCount(workout),
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
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.only(left: 16, top: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            // Adicionar aos favoritos
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.favorite_border,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutInfo(BuildContext context, Workout workout) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildInfoItem(
            icon: Icons.timer,
            label: 'Duração',
            value: '${workout.durationMinutes} min',
            color: Colors.blue,
          ),
          _buildInfoDivider(),
          _buildInfoItem(
            icon: Icons.local_fire_department,
            label: 'Calorias',
            value: 'Não disponível',
            color: Colors.orange,
          ),
          _buildInfoDivider(),
          _buildInfoItem(
            icon: Icons.sync,
            label: 'Nível',
            value: workout.difficulty,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildWorkoutDescription(BuildContext context, Workout workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          workout.description,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context, Workout workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Exercícios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              _getTotalExerciseCount(workout),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Iterar sobre as seções de exercícios
        ...workout.sections.asMap().entries.map((entry) {
          final section = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome da seção
              if (section.name.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    section.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              
              // Exercícios da seção
              ...section.exercises.asMap().entries.map((exerciseEntry) {
                final index = exerciseEntry.key;
                final exerciseName = exerciseEntry.value.name;
                
                return _buildExerciseCard(
                  context, 
                  exerciseName, 
                  'Realize o exercício conforme demonstrado', 
                  index
                );
              }).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExerciseCard(BuildContext context, String name, String detail, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primaryLight.withOpacity(0.2),
          ),
          child: Center(
            child: Icon(
              Icons.fitness_center,
              color: AppColors.primary,
              size: 30,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            detail,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
            ),
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        onTap: () {
          // Abrir detalhes do exercício ou vídeo tutorial
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Workout workout) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Iniciar treino
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Iniciar Treino',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: AppColors.primary,
            ),
            onPressed: () {
              // Compartilhar treino
            },
          ),
        ),
      ],
    );
  }

  String _getTotalExerciseCount(Workout workout) {
    int totalExercises = 0;
    for (var section in workout.sections) {
      totalExercises += section.exercises.length;
    }
    return '$totalExercises exercícios';
  }
} 
