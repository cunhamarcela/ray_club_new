// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../models/redeemed_benefit.dart';
import '../viewmodels/benefit_view_model.dart';

/// Tela de detalhes de um benefício resgatado
@RoutePage()
class RedeemedBenefitDetailScreen extends ConsumerWidget {
  /// Construtor
  const RedeemedBenefitDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtém o estado do ViewModel
    final state = ref.watch(benefitViewModelProvider);
    
    // Se não houver benefício resgatado selecionado, volta para a tela anterior
    if (state.selectedRedeemedBenefit == null && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }
    
    // Se estiver carregando, exibe indicador de carregamento
    if (state.isLoading) {
      return const Scaffold(
        body: LoadingView(message: 'Carregando detalhes...'),
      );
    }
    
    // Se houver erro, exibe mensagem de erro
    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: state.errorMessage!,
          onRetry: () {
            if (state.selectedRedeemedBenefit != null) {
              ref.read(benefitViewModelProvider.notifier)
                .selectRedeemedBenefit(state.selectedRedeemedBenefit!.id);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    }
    
    // Obtém o benefício resgatado selecionado
    final redeemedBenefit = state.selectedRedeemedBenefit!;
    final hasSnapshot = redeemedBenefit.benefitSnapshot != null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benefício Resgatado'),
        actions: [
          if (redeemedBenefit.status == RedemptionStatus.active)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showActionsMenu(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do benefício
            if (hasSnapshot && redeemedBenefit.benefitSnapshot!.imageUrl.isNotEmpty)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                redeemedBenefit.benefitSnapshot!.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            )
            else
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(
                  Icons.card_giftcard,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status do benefício
                  _buildStatusBadge(redeemedBenefit.status),
                  const SizedBox(height: 16),
                  
                  // Título do benefício
                  Text(
                    hasSnapshot 
                        ? redeemedBenefit.benefitSnapshot!.title 
                        : 'Benefício Resgatado',
                    style: AppTypography.headline,
                  ),
                  
                  // Parceiro (se disponível)
                  if (hasSnapshot && redeemedBenefit.benefitSnapshot!.partner != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storefront,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          redeemedBenefit.benefitSnapshot!.partner!,
                          style: AppTypography.subtitle,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Código de resgate
                  Text(
                    'Código de Resgate',
                    style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Container com o código
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                redeemedBenefit.redemptionCode,
                                style: AppTypography.headline.copyWith(
                                  fontFamily: 'Courier',
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(
                                context, 
                                redeemedBenefit.redemptionCode,
                              ),
                              tooltip: 'Copiar código',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Apresente este código para resgatar seu benefício',
                          style: AppTypography.body2,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Informações do benefício
                  Text(
                    'Informações',
                    style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Data de resgate
                  _buildInfoItem(
                    icon: Icons.calendar_today,
                    title: 'Data de resgate',
                    content: _formatDate(redeemedBenefit.redeemedAt),
                  ),
                  
                  // Data de expiração
                  if (redeemedBenefit.expiresAt != null)
                  _buildInfoItem(
                    icon: Icons.access_time,
                    title: 'Expira em',
                    content: _formatDate(redeemedBenefit.expiresAt!),
                    isWarning: _isNearExpiry(redeemedBenefit.expiresAt!),
                  ),
                  
                  // Data de uso
                  if (redeemedBenefit.status == RedemptionStatus.used && 
                      redeemedBenefit.usedAt != null)
                  _buildInfoItem(
                    icon: Icons.check_circle_outline,
                    title: 'Utilizado em',
                    content: _formatDate(redeemedBenefit.usedAt!),
                    isSuccess: true,
                  ),
                  
                  // Descrição do benefício
                  if (hasSnapshot)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Descrição',
                        style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        redeemedBenefit.benefitSnapshot!.description,
                        style: AppTypography.body1,
                      ),
                    ],
                  ),
                  
                  // Termos e condições
                  if (hasSnapshot && 
                      redeemedBenefit.benefitSnapshot!.termsAndConditions != null &&
                      redeemedBenefit.benefitSnapshot!.termsAndConditions!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Termos e Condições',
                        style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        redeemedBenefit.benefitSnapshot!.termsAndConditions!,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Botão para marcar como utilizado (apenas se estiver ativo)
                  if (redeemedBenefit.status == RedemptionStatus.active)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsUsed(context, ref),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Marcar como Utilizado'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
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
  
  // Exibe o menu de ações para o benefício
  void _showActionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle, color: AppColors.success),
                  title: const Text('Marcar como Utilizado'),
                  onTap: () {
                    Navigator.pop(context);
                    _markAsUsed(context, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: AppColors.error),
                  title: const Text('Cancelar Resgate'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmCancelRedemption(context, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: AppColors.primary),
                  title: const Text('Compartilhar'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implementar compartilhamento
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Marca um benefício como utilizado
  void _markAsUsed(BuildContext context, WidgetRef ref) async {
    final state = ref.read(benefitViewModelProvider);
    
    if (state.selectedRedeemedBenefit == null) return;
    
    // Pede confirmação
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como utilizado?'),
        content: const Text(
          'Esta ação não pode ser desfeita. Confirme apenas se você já utilizou este benefício.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    
    if (shouldProceed != true || !context.mounted) return;
    
    // Marca como utilizado
    final success = await ref.read(benefitViewModelProvider.notifier)
      .markBenefitAsUsed(state.selectedRedeemedBenefit!.id);
    
    if (!context.mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Benefício marcado como utilizado com sucesso'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Não foi possível marcar o benefício como utilizado'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  // Confirma o cancelamento do resgate
  void _confirmCancelRedemption(BuildContext context, WidgetRef ref) async {
    final state = ref.read(benefitViewModelProvider);
    
    if (state.selectedRedeemedBenefit == null) return;
    
    // Pede confirmação
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar resgate?'),
        content: const Text(
          'Ao cancelar o resgate, você receberá seus pontos de volta. Esta ação não pode ser desfeita.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
    
    if (shouldProceed != true || !context.mounted) return;
    
    // Cancela o resgate
    final success = await ref.read(benefitViewModelProvider.notifier)
      .cancelRedeemedBenefit(state.selectedRedeemedBenefit!.id);
    
    if (!context.mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resgate cancelado com sucesso. Seus pontos foram devolvidos.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context); // Volta para a lista de benefícios resgatados
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Não foi possível cancelar o resgate'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  // Copia o código para a área de transferência
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  // Widget para exibir o badge de status
  Widget _buildStatusBadge(RedemptionStatus status) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case RedemptionStatus.active:
        badgeColor = AppColors.success;
        statusText = 'Ativo';
        statusIcon = Icons.check_circle;
        break;
      case RedemptionStatus.used:
        badgeColor = AppColors.primary;
        statusText = 'Utilizado';
        statusIcon = Icons.verified;
        break;
      case RedemptionStatus.expired:
        badgeColor = AppColors.error;
        statusText = 'Expirado';
        statusIcon = Icons.timer_off;
        break;
      case RedemptionStatus.cancelled:
        badgeColor = Colors.grey;
        statusText = 'Cancelado';
        statusIcon = Icons.cancel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: AppTypography.body2.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para exibir um item de informação
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
    bool isWarning = false,
    bool isSuccess = false,
  }) {
    Color iconColor = AppColors.textSecondary;
    if (isWarning) iconColor = AppColors.warning;
    if (isSuccess) iconColor = AppColors.success;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  content,
                  style: AppTypography.body1.copyWith(
                    fontWeight: isWarning || isSuccess ? FontWeight.bold : FontWeight.normal,
                    color: isWarning ? AppColors.warning : (isSuccess ? AppColors.success : null),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Formata a data para exibição
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // Verifica se a data de expiração está próxima
  bool _isNearExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }
} 
