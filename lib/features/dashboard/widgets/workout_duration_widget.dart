// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';

/// Widget que exibe o progresso de tempo de treino
class WorkoutDurationWidget extends ConsumerWidget {
  /// Construtor
  const WorkoutDurationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acesso aos dados através do provider
    final userProgressAsync = ref.watch(userProgressProvider);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userProgressAsync.when(
          data: (userProgress) {
            // Meta semanal em minutos (padrão: 180 minutos, ou 3 horas)
            const weeklyGoalMinutes = 180;
            
            // Tempo total da semana
            final weeklyDuration = userProgress.recentWorkoutsDuration ?? 0;
            
            // Calcular percentual (limitado a 100%)
            final weeklyPercent = (weeklyDuration / weeklyGoalMinutes).clamp(0.0, 1.0);
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Progresso de Tempo',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicador circular de progresso
                    CircularPercentIndicator(
                      radius: 45.0,
                      lineWidth: 10.0,
                      percent: weeklyPercent,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$weeklyDuration',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'min',
                            style: AppTypography.labelSmall,
                          ),
                        ],
                      ),
                      progressColor: AppColors.primary,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 16),
                    // Informações da meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meta Semanal',
                            style: AppTypography.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$weeklyDuration/$weeklyGoalMinutes min',
                            style: AppTypography.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: weeklyPercent,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(weeklyPercent * 100).toInt()}% concluído',
                            style: AppTypography.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tempo total de treino nesta semana. Continue assim!',
                  style: AppTypography.bodySmall,
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => SizedBox(
            height: 150,
            child: Center(
              child: Text(
                'Erro ao carregar os dados de tempo',
                style: AppTypography.bodyMedium.copyWith(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 