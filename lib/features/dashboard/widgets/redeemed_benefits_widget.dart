// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';

/// Widget que exibe os benefícios resgatados pelo usuário
class RedeemedBenefitsWidget extends ConsumerWidget {
  /// Construtor
  const RedeemedBenefitsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar benefícios resgatados
    final benefitsAsyncValue = ref.watch(redeemedBenefitsProvider);
    
    return benefitsAsyncValue.when(
      data: (benefits) => _buildBenefitsCard(context, benefits),
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
                'Erro ao carregar benefícios',
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
  
  /// Constrói o card de benefícios resgatados
  Widget _buildBenefitsCard(BuildContext context, List<RedeemedBenefit> benefits) {
    if (benefits.isEmpty) {
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
                  const Icon(Icons.card_giftcard, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text(
                    'Benefícios Resgatados',
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
                      Icons.redeem,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Você ainda não resgatou benefícios',
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Acumule pontos e resgate benefícios exclusivos',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navegar para a tela de benefícios
                        context.router.pushNamed('/benefits');
                      },
                      icon: const Icon(Icons.card_giftcard),
                      label: const Text('Ver Benefícios'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.info,
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
            // Título e botão de ver todos
            Row(
              children: [
                const Icon(Icons.card_giftcard, color: AppColors.info),
                const SizedBox(width: 8),
                Text(
                  'Benefícios Resgatados',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navegar para tela de benefícios
                    context.router.pushNamed('/benefits');
                  },
                  child: const Text('Ver Todos'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Lista de benefícios resgatados
            ...benefits.take(3).map((benefit) => 
              _buildBenefitItem(context, benefit),
            ),
            
            // Se houver mais de 3 benefícios, mostrar botão de ver mais
            if (benefits.length > 3) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () {
                    // Navegar para tela de benefícios
                    context.router.pushNamed('/benefits');
                  },
                  icon: const Icon(Icons.more_horiz),
                  label: Text(
                    'Ver mais ${benefits.length - 3} benefícios',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Constrói um item de benefício individual
  Widget _buildBenefitItem(BuildContext context, RedeemedBenefit benefit) {
    // Formatar data de resgate
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = benefit.redeemedAt != null 
        ? dateFormat.format(benefit.redeemedAt!)
        : 'Data desconhecida';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagem do benefício (ou placeholder)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: benefit.imageUrl != null
                ? Image.network(
                    benefit.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.info.withOpacity(0.2),
                      child: const Icon(Icons.card_giftcard, color: AppColors.info),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.info.withOpacity(0.2),
                    child: const Icon(Icons.card_giftcard, color: AppColors.info),
                  ),
          ),
          
          const SizedBox(width: 12),
          
          // Informações do benefício
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.benefitTitle ?? 'Benefício Resgatado',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Resgatado em: $formattedDate',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                if (benefit.redemptionCode != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.code, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Código: ${benefit.redemptionCode}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Status de expiração
          if (benefit.expiresAt != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isExpired(benefit) 
                    ? Colors.red.withOpacity(0.1) 
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _isExpired(benefit) ? 'Expirado' : 'Válido',
                style: AppTypography.bodySmall.copyWith(
                  color: _isExpired(benefit) ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Verifica se o benefício está expirado
  bool _isExpired(RedeemedBenefit benefit) {
    if (benefit.expiresAt == null) return false;
    
    final now = DateTime.now();
    return now.isAfter(benefit.expiresAt!);
  }
} 