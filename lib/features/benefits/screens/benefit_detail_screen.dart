// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../viewmodels/benefit_view_model.dart';

/// Tela de detalhes de um benefício
@RoutePage()
class BenefitDetailScreen extends ConsumerWidget {
  /// Construtor
  const BenefitDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtém o estado do ViewModel
    final state = ref.watch(benefitViewModelProvider);
    
    // Se não houver benefício selecionado, volta para a tela anterior
    if (state.selectedBenefit == null && !state.isLoading) {
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
            if (state.selectedBenefit != null) {
              ref.read(benefitViewModelProvider.notifier)
                .selectBenefit(state.selectedBenefit!.id);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    }
    
    // Obtém o benefício selecionado
    final benefit = state.selectedBenefit!;
    final canAfford = state.userPoints != null && state.userPoints! >= benefit.pointsRequired;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar com imagem
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: benefit.imageUrl.isNotEmpty
                  ? Image.network(
                      benefit.imageUrl,
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
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.card_giftcard,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ),
          
          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e parceiro
                  Row(
                    children: [
                      if (benefit.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Destaque',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      Expanded(
                        child: Text(
                          benefit.title,
                          style: AppTypography.headline,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // Parceiro
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
                          benefit.partner,
                          style: AppTypography.subtitle,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Pontos necessários
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: canAfford ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: canAfford ? AppColors.success : AppColors.error,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: canAfford ? AppColors.success : AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${benefit.pointsRequired} pontos necessários',
                                style: AppTypography.subtitle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: canAfford ? AppColors.success : AppColors.error,
                                ),
                              ),
                              if (state.userPoints != null)
                              Text(
                                canAfford
                                    ? 'Você tem ${state.userPoints} pontos disponíveis'
                                    : 'Você tem apenas ${state.userPoints} pontos (faltam ${benefit.pointsRequired - state.userPoints!})',
                                style: AppTypography.body2.copyWith(
                                  color: canAfford ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Descrição
                  Text(
                    'Descrição',
                    style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    benefit.description,
                    style: AppTypography.body1,
                  ),
                  
                  // Informações adicionais
                  const SizedBox(height: 24),
                  Text(
                    'Informações',
                    style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Data de expiração
                  if (benefit.expirationDate != null)
                  _buildInfoItem(
                    icon: Icons.event,
                    title: 'Data de expiração',
                    content: _formatDate(benefit.expirationDate),
                  ),
                  
                  // Quantidade disponível
                  _buildInfoItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Quantidade disponível',
                    content: '${benefit.availableQuantity}',
                    isWarning: benefit.availableQuantity < 5,
                  ),
                  
                  // Código promocional
                  if (benefit.promoCode != null && benefit.promoCode!.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Código promocional',
                    content: benefit.promoCode!,
                  ),
                  
                  // Termos e condições
                  if (benefit.termsAndConditions != null && benefit.termsAndConditions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Termos e Condições',
                          style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          benefit.termsAndConditions!,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Espaço para o botão fixo não cobrir o conteúdo
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Botão de resgate fixo na parte inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: canAfford && !state.isRedeeming
                ? () => _redeemBenefit(context, ref)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: state.isRedeeming
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Processando...'),
                    ],
                  )
                : Text(
                    canAfford ? 'Resgatar benefício' : 'Pontos insuficientes',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
  
  // Widget para exibir um item de informação
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isWarning ? AppColors.warning : AppColors.textSecondary,
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
                    fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                    color: isWarning ? AppColors.warning : null,
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
  
  // Resgata o benefício
  void _redeemBenefit(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(benefitViewModelProvider.notifier);
    final state = ref.read(benefitViewModelProvider);
    
    if (state.selectedBenefit == null) return;
    
    final result = await viewModel.redeemBenefit(state.selectedBenefit!.id);
    
    if (result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/benefits/redeemed');
      });
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Não foi possível resgatar o benefício'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
} 
