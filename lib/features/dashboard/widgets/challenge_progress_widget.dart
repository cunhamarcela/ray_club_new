// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/features/challenges/providers/challenge_providers.dart';

/// Widget que exibe o progresso do desafio atual no dashboard
class ChallengeProgressWidget extends ConsumerWidget {
  /// Construtor
  const ChallengeProgressWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar o desafio atual e progresso
    final challengeAsyncValue = ref.watch(currentChallengeProvider);
    final progressAsyncValue = ref.watch(challengeProgressProvider);
    
    // Combinar estados para exibir o widget
    return challengeAsyncValue.when(
      data: (challenge) {
        if (challenge == null) {
          return _buildNoActiveChallenge(context);
        }
        
        return progressAsyncValue.when(
          data: (progress) => _buildChallengeProgress(context, ref, challenge, progress),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stackTrace) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'Erro ao carregar progresso do desafio',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => ref.refresh(dashboardViewModelProvider),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Erro ao carregar desafio',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => ref.refresh(dashboardViewModelProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói a visualização quando não há desafio ativo
  Widget _buildNoActiveChallenge(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Desafio Atual',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum desafio ativo',
                    style: AppTypography.titleSmall.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Participe de um desafio para acompanhar seu progresso aqui',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navegar para a lista de desafios
                      context.router.push(const ChallengesListRoute());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ver Desafios'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
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
  
  /// Constrói o card de progresso do desafio
  Widget _buildChallengeProgress(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
    ChallengeProgress? progress,
  ) {
    final completionPercentage = progress?.completionPercentage ?? 0.0;
    final daysLeft = _calculateDaysLeft(challenge);
    final isCompleted = completionPercentage >= 100;
    
    // Obter o ranking do desafio (top 3)
    final rankingAsync = ref.watch(challengeTopRankingProvider(challenge.id));
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: challenge.isOfficial
                ? [AppColors.primary, AppColors.primaryDark]
                : [AppColors.accent, AppColors.accent.withOpacity(0.8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e tipo de desafio
              Row(
                children: [
                  Icon(
                    challenge.isOfficial ? Icons.star : Icons.emoji_events,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      challenge.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${completionPercentage.toInt()}%',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Barra de progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  minHeight: 12,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Estatísticas do desafio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pontos
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seus pontos',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress?.points ?? 0}',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Posição no ranking
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sua posição',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '#${progress?.position ?? '-'}',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _getPositionIcon(progress?.position),
                            color: _getPositionColor(progress?.position),
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Dias restantes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restante',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$daysLeft dias',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Ranking dos melhores participantes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top 3 Participantes',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navegar para o ranking completo
                          context.router.push(ChallengeRankingRoute(challengeId: challenge.id));
                        },
                        child: Text(
                          'Ver todos',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  rankingAsync.when(
                    data: (topParticipants) {
                      if (topParticipants.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Nenhum participante registrado ainda',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: [
                          ...topParticipants.asMap().entries.map((entry) {
                            final index = entry.key;
                            final participant = entry.value;
                            return _buildRankingItem(context, index + 1, participant);
                          }),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    error: (_, __) => Text(
                      'Não foi possível carregar o ranking',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Navegar para os detalhes do desafio
                        context.router.push(ChallengeDetailRoute(challengeId: challenge.id));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Detalhes'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar para a tela de registrar atividade
                        context.router.push(ChallengeDetailRoute(challengeId: challenge.id));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: challenge.isOfficial ? AppColors.primary : AppColors.accent,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Registrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói um item de ranking
  Widget _buildRankingItem(BuildContext context, int position, ChallengeProgress participant) {
    final medalColors = [
      Colors.amber.shade300, // Ouro
      Colors.grey.shade300,  // Prata
      Colors.orange.shade300, // Bronze
    ];

    final medalColor = position <= 3 ? medalColors[position - 1] : Colors.white.withOpacity(0.5);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                position <= 3 ? Icons.emoji_events : Icons.person,
                color: medalColor,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              participant.userName ?? 'Anônimo',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: position <= 3 ? FontWeight.w700 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${participant.points} pts',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Calcula quantos dias faltam para o término do desafio
  int _calculateDaysLeft(Challenge challenge) {
    if (challenge.endDate == null) return 0;
    
    final now = DateTime.now();
    final endDate = challenge.endDate!;
    
    if (endDate.isBefore(now)) return 0;
    
    return endDate.difference(now).inDays + 1;
  }
  
  /// Retorna o ícone apropriado com base na posição
  IconData _getPositionIcon(int? position) {
    if (position == null) return Icons.help_outline;
    
    if (position <= 3) return Icons.arrow_upward;
    if (position <= 10) return Icons.trending_up;
    if (position <= 20) return Icons.trending_flat;
    
    return Icons.trending_down;
  }
  
  /// Retorna a cor apropriada com base na posição
  Color _getPositionColor(int? position) {
    if (position == null) return Colors.grey;
    
    if (position <= 3) return Colors.green;
    if (position <= 10) return Colors.lime;
    if (position <= 20) return Colors.amber;
    
    return Colors.red.shade300;
  }
} 