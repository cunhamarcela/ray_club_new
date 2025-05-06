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
import '../models/redeemed_benefit.dart';
import '../viewmodels/benefit_view_model.dart';
import '../widgets/redeemed_benefit_card.dart';

/// Tela de listagem de benefícios resgatados pelo usuário
@RoutePage()
class RedeemedBenefitsScreen extends ConsumerStatefulWidget {
  /// Construtor
  const RedeemedBenefitsScreen({super.key});

  @override
  ConsumerState<RedeemedBenefitsScreen> createState() => _RedeemedBenefitsScreenState();
}

class _RedeemedBenefitsScreenState extends ConsumerState<RedeemedBenefitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializa o TabController
    _tabController = TabController(length: 3, vsync: this);
    
    // Carrega os benefícios resgatados quando a tela é inicializada
    Future.microtask(() {
      ref.read(benefitViewModelProvider.notifier).loadRedeemedBenefits();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Obtém o estado do ViewModel
    final state = ref.watch(benefitViewModelProvider);
    
    // Se estiver carregando, exibe indicador de carregamento
    if (state.isLoading) {
      return const Scaffold(
        body: LoadingView(message: 'Carregando seus benefícios...'),
      );
    }
    
    // Se houver erro, exibe mensagem de erro
    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meus Benefícios')),
        body: ErrorView(
          message: state.errorMessage!,
          onRetry: () => ref.read(benefitViewModelProvider.notifier).loadRedeemedBenefits(),
        ),
      );
    }
    
    // Filtra os benefícios por status
    final activeAndAvailable = state.redeemedBenefits.where((b) => 
      b.status == RedemptionStatus.active).toList();
    
    final used = state.redeemedBenefits.where((b) => 
      b.status == RedemptionStatus.used).toList();
    
    final expiredOrCancelled = state.redeemedBenefits.where((b) => 
      b.status == RedemptionStatus.expired || 
      b.status == RedemptionStatus.cancelled).toList();
    
    // Lista de benefícios por tab
    final benefitsByTab = [activeAndAvailable, used, expiredOrCancelled];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Benefícios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ativos'),
            Tab(text: 'Utilizados'),
            Tab(text: 'Expirados'),
          ],
        ),
      ),
      body: state.redeemedBenefits.isEmpty
          ? _buildEmptyState()
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Benefícios ativos
                _buildTabContent(activeAndAvailable, 'Você não tem benefícios ativos'),
                
                // Tab 2: Benefícios utilizados
                _buildTabContent(used, 'Você não tem benefícios utilizados'),
                
                // Tab 3: Benefícios expirados/cancelados
                _buildTabContent(expiredOrCancelled, 'Você não tem benefícios expirados ou cancelados'),
              ],
            ),
    );
  }
  
  // Constrói o conteúdo de uma tab
  Widget _buildTabContent(List<RedeemedBenefit> benefits, String emptyMessage) {
    if (benefits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_giftcard,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: AppTypography.subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RedeemedBenefitCard(
            redeemedBenefit: benefit,
            onTap: () => _navigateToRedeemedBenefitDetail(benefit.id),
          ),
        );
      },
    );
  }
  
  // Constrói o estado vazio (quando não há benefícios resgatados)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Você ainda não resgatou nenhum benefício',
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Resgate benefícios utilizando seus pontos e eles aparecerão aqui',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/benefits'),
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Ver benefícios disponíveis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Navega para a tela de detalhes de um benefício resgatado
  void _navigateToRedeemedBenefitDetail(String redeemedBenefitId) {
    ref.read(benefitViewModelProvider.notifier).selectRedeemedBenefit(redeemedBenefitId);
    Navigator.pushNamed(context, '/benefits/redeemed/detail');
  }
} 
