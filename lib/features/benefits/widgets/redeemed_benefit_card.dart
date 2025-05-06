// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/redeemed_benefit.dart';

/// Widget para exibir um benefício resgatado em forma de card
class RedeemedBenefitCard extends StatelessWidget {
  /// Benefício resgatado a ser exibido
  final RedeemedBenefit redeemedBenefit;
  
  /// Callback quando o card for tocado
  final VoidCallback? onTap;

  /// Construtor
  const RedeemedBenefitCard({
    super.key,
    required this.redeemedBenefit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Cores baseadas no status
    final Color statusColor = _getStatusColor();
    final String statusText = _getStatusText();
    
    // Verifica se tem snapshot do benefício
    final hasSnapshot = redeemedBenefit.benefitSnapshot != null;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem e badge com status
            Stack(
              children: [
                // Imagem do benefício
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: hasSnapshot && redeemedBenefit.benefitSnapshot!.imageUrl.isNotEmpty
                      ? Image.network(
                          redeemedBenefit.benefitSnapshot!.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.card_giftcard,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
                
                // Overlay gradiente para melhor legibilidade
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Badge com status
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Informações do benefício
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    hasSnapshot ? redeemedBenefit.benefitSnapshot!.title : 'Benefício Resgatado',
                    style: AppTypography.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Código de resgate
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Código: ${redeemedBenefit.redemptionCode}',
                          style: AppTypography.body2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Data de resgate
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Resgatado em ${_formatDate(redeemedBenefit.redeemedAt)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Data de expiração
                  if (redeemedBenefit.expiresAt != null && 
                      redeemedBenefit.status != RedemptionStatus.used &&
                      redeemedBenefit.status != RedemptionStatus.cancelled)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: _isNearExpiry() ? AppColors.warning : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expira em ${_formatExpiryDate()}',
                          style: AppTypography.caption.copyWith(
                            color: _isNearExpiry() ? AppColors.warning : AppColors.textSecondary,
                            fontWeight: _isNearExpiry() ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Data de uso para benefícios usados
                  if (redeemedBenefit.status == RedemptionStatus.used && redeemedBenefit.usedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Utilizado em ${_formatDate(redeemedBenefit.usedAt!)}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
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
  
  /// Retorna a cor associada ao status do benefício
  Color _getStatusColor() {
    switch (redeemedBenefit.status) {
      case RedemptionStatus.active:
        return AppColors.success;
      case RedemptionStatus.used:
        return AppColors.primary;
      case RedemptionStatus.expired:
        return AppColors.error;
      case RedemptionStatus.cancelled:
        return Colors.grey;
    }
  }
  
  /// Retorna texto representando o status do benefício
  String _getStatusText() {
    switch (redeemedBenefit.status) {
      case RedemptionStatus.active:
        return 'Ativo';
      case RedemptionStatus.used:
        return 'Utilizado';
      case RedemptionStatus.expired:
        return 'Expirado';
      case RedemptionStatus.cancelled:
        return 'Cancelado';
    }
  }
  
  /// Verifica se o benefício está próximo da data de expiração
  bool _isNearExpiry() {
    if (redeemedBenefit.expiresAt == null) return false;
    
    final now = DateTime.now();
    final daysUntilExpiry = redeemedBenefit.expiresAt!.difference(now).inDays;
    
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }
  
  /// Formata a data de expiração para exibição
  String _formatExpiryDate() {
    if (redeemedBenefit.expiresAt == null) return '';
    
    final now = DateTime.now();
    final difference = redeemedBenefit.expiresAt!.difference(now).inDays;
    
    if (difference <= 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Amanhã';
    } else if (difference < 30) {
      return '$difference dias';
    } else {
      return '${redeemedBenefit.expiresAt!.day}/${redeemedBenefit.expiresAt!.month}/${redeemedBenefit.expiresAt!.year}';
    }
  }
  
  /// Formata a data para exibição
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 
