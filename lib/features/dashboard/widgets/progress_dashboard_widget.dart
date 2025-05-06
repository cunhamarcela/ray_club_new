// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';

/// Widget que exibe o dashboard de progresso do usuário
class ProgressDashboardWidget extends ConsumerWidget {
  /// Construtor
  const ProgressDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar o progresso do usuário
    final progressAsyncValue = ref.watch(userProgressProvider);
    
    return progressAsyncValue.when(
      data: (progress) => _buildProgressDashboard(context, progress),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Não foi possível carregar o progresso',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dashboardViewModelProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói o dashboard com os dados de progresso
  Widget _buildProgressDashboard(BuildContext context, UserProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seu Progresso',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Grid com os principais indicadores
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 1.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                context,
                title: 'Treinos',
                value: progress.totalWorkouts.toString(),
                icon: Icons.fitness_center,
                iconColor: Colors.orange,
              ),
              _buildStatCard(
                context,
                title: 'Streak Atual',
                value: '${progress.currentStreak} dias',
                icon: Icons.local_fire_department,
                iconColor: Colors.red,
              ),
              _buildStatCard(
                context,
                title: 'Tempo Total',
                value: _formatDuration(progress.totalDuration),
                icon: Icons.timer,
                iconColor: Colors.blue,
              ),
              _buildStatCard(
                context,
                title: 'Pontos',
                value: progress.totalPoints.toString(),
                icon: Icons.star,
                iconColor: Colors.amber,
              ),
            ],
          ),
          
          // Barra de progresso com indicador de treinos no mês
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Treinos este mês:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              Text(
                '${progress.daysTrainedThisMonth}/30',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.daysTrainedThisMonth / 30,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          
          // Tipos de treino
          if (progress.workoutsByType.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Tipos de Treino',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...progress.workoutsByType.entries.map((entry) => 
              _buildWorkoutTypeProgressBar(
                context, 
                type: entry.key, 
                count: entry.value,
                total: progress.totalWorkouts,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Constrói card de estatística individual
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Constrói barra de progresso para tipo de treino
  Widget _buildWorkoutTypeProgressBar(
    BuildContext context, {
    required String type,
    required int count,
    required int total,
  }) {
    // Calcula a porcentagem deste tipo em relação ao total
    final percentage = total > 0 ? count / total : 0.0;
    
    // Obtém cor correspondente ao tipo de treino
    final color = _getColorForWorkoutType(type);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                type.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$count treinos (${(percentage * 100).toInt()}%)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
  
  // Formata a duração de minutos para horas:minutos
  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  // Retorna cor correspondente ao tipo de treino
  Color _getColorForWorkoutType(String type) {
    // Converte o tipo para minúsculas para comparação case-insensitive
    final lowerType = type.toLowerCase();
    
    if (lowerType.contains('cardio') || lowerType.contains('aeróbico')) {
      return Colors.red;
    } else if (lowerType.contains('força') || lowerType.contains('resistência')) {
      return Colors.blue;
    } else if (lowerType.contains('flexibility') || lowerType.contains('flexibilidade')) {
      return Colors.purple;
    } else if (lowerType.contains('hiit') || lowerType.contains('interval')) {
      return Colors.orange;
    } else {
      return Colors.teal;
    }
  }
} 