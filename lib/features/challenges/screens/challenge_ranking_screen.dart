import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textures.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/providers/auth_provider.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/challenge.dart';
import '../models/challenge_progress.dart';
import '../providers/challenge_provider.dart';
import '../repositories/challenge_repository.dart' show ChallengeRepository;

/// Tela temporária para visualizar o ranking de um desafio
@RoutePage()
class ChallengeRankingScreen extends ConsumerWidget {
  final String challengeId;
  
  const ChallengeRankingScreen({
    Key? key,
    @PathParam('challengeId') required this.challengeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(challengeByIdProvider(challengeId));
    final realtimeProgressAsync = ref.watch(realtimeProgressProvider(challengeId));
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.id;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ranking',
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: challengeAsync.when(
        data: (challenge) => _buildContent(context, challenge, realtimeProgressAsync, userId, ref),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => EmptyState(
          message: 'Não foi possível carregar o desafio.',
          icon: Icons.error_outline,
          onAction: () => ref.refresh(challengeByIdProvider(challengeId)),
          actionLabel: 'Tentar novamente',
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, 
    Challenge challenge, 
    AsyncValue<List<ChallengeProgress>> realtimeProgressAsync,
    String? userId,
    WidgetRef ref,
  ) {
    return realtimeProgressAsync.when(
      data: (progressList) {
        if (progressList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ainda não há participantes neste desafio',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(realtimeProgressProvider(challenge.id)),
                  child: const Text('Atualizar'),
                ),
              ],
            ),
          );
        }
        
        // Ordenar por pontos (do maior para o menor)
        final sortedList = [...progressList]
          ..sort((a, b) => b.points.compareTo(a.points));
          
        // Encontrar posição do usuário atual para fazer scroll automático
        int currentUserIndex = -1;
        if (userId != null) {
          currentUserIndex = sortedList.indexWhere((progress) => progress.userId == userId);
        }
        
        return Column(
          children: [
            // Cabeçalho com informações do desafio
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      challenge.isOfficial ? AppColors.primary : AppColors.accent,
                      challenge.isOfficial ? AppColors.primary.withOpacity(0.8) : AppColors.accent.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: AppTypography.headingSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${sortedList.length} participantes',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pontos totais: ${_calculateTotalPoints(sortedList)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Cabeçalho da tabela
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Pos.',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        'Participante',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Pontos',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Check-ins',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Lista de participantes
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  itemCount: sortedList.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final progress = sortedList[index];
                    final isCurrentUser = progress.userId == userId;
                    
                    return FadeInRight(
                      duration: const Duration(milliseconds: 300),
                      delay: Duration(milliseconds: index * 30),
                      child: _buildParticipantRow(
                        context,
                        progress,
                        index + 1, // posição começa em 1
                        isHighlighted: isCurrentUser,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => EmptyState(
        icon: Icons.error_outline,
        message: 'Não foi possível carregar o ranking.',
        onAction: () => ref.refresh(realtimeProgressProvider(challengeId)),
        actionLabel: 'Tentar novamente',
      ),
    );
  }

  Widget _buildParticipantRow(
    BuildContext context,
    ChallengeProgress progress,
    int position,
    {bool isHighlighted = false}
  ) {
    Color positionColor;
    IconData? positionIcon;

    // Definir cor e ícone com base na posição
    if (position == 1) {
      positionColor = const Color(0xFFFFD700); // Ouro
      positionIcon = Icons.emoji_events;
    } else if (position == 2) {
      positionColor = const Color(0xFFC0C0C0); // Prata
      positionIcon = Icons.emoji_events;
    } else if (position == 3) {
      positionColor = const Color(0xFFCD7F32); // Bronze
      positionIcon = Icons.emoji_events;
    } else {
      positionColor = AppColors.textSecondary;
      positionIcon = null;
    }

    return Container(
      color: isHighlighted ? AppColors.cream.withOpacity(0.3) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Posição
          Expanded(
            flex: 1,
            child: positionIcon != null
                ? Icon(
                    positionIcon,
                    color: positionColor,
                    size: 24,
                  )
                : Text(
                    '$position',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: positionColor,
                    ),
                  ),
          ),
          // Participante
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isHighlighted ? AppColors.primary : AppColors.primaryLight,
                    shape: BoxShape.circle,
                    image: progress.userPhotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(progress.userPhotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: progress.userPhotoUrl == null
                      ? Icon(
                          Icons.person,
                          color: isHighlighted ? Colors.white : AppColors.primary,
                          size: 18,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${progress.userName}${isHighlighted ? ' (Você)' : ''}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: isHighlighted || position <= 3 ? FontWeight.w700 : FontWeight.w500,
                          color: isHighlighted ? AppColors.secondary : AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (progress.lastCheckIn != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Último check-in: ${_formatDate(progress.lastCheckIn!)}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Pontos
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighlighted ? AppColors.secondary.withOpacity(0.1) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${progress.points}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isHighlighted 
                        ? AppColors.secondary 
                        : (position <= 3 ? AppColors.primary : AppColors.textDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Check-ins
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.checkInsCount ?? 0}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  if (progress.consecutiveDays != null && progress.consecutiveDays! > 1) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: AppColors.accent,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${progress.consecutiveDays}',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para formatar a data do último check-in
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'há ${difference.inMinutes} min';
      }
      return 'há ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else {
      return 'há ${difference.inDays} dias';
    }
  }
  
  // Função para calcular o total de pontos do desafio
  int _calculateTotalPoints(List<ChallengeProgress> progressList) {
    return progressList.fold(0, (sum, progress) => sum + progress.points);
  }
}

// Stream provider para o ranking em tempo real
final realtimeProgressProvider = StreamProvider.family<List<ChallengeProgress>, String>((ref, challengeId) {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.watchChallengeParticipants(challengeId);
}); 