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
import '../../../shared/bottom_navigation_bar.dart';
import '../viewmodels/benefit_view_model.dart';
import '../widgets/benefit_card.dart';

/// Tela de listagem de benefícios disponíveis
@RoutePage()
class BenefitsListScreen extends ConsumerStatefulWidget {
  /// Construtor
  const BenefitsListScreen({super.key});

  @override
  ConsumerState<BenefitsListScreen> createState() => _BenefitsListScreenState();
}

class _BenefitsListScreenState extends ConsumerState<BenefitsListScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isTabControllerInitialized = false;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializa com um valor padrão até que as categorias sejam carregadas
    _tabController = TabController(length: 1, vsync: this);
    
    // Carrega os benefícios quando a tela é inicializada
    Future.microtask(() {
      ref.read(benefitViewModelProvider.notifier).loadBenefits();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _updateTabController(int length) {
    // Descarta o controlador antigo
    if (_isTabControllerInitialized) {
      _tabController.dispose();
    }
    
    // Cria um novo controlador
    _tabController = TabController(length: length, vsync: this);
    _isTabControllerInitialized = true;
    
    // Adiciona listener para mudar a categoria quando a tab mudar
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final state = ref.read(benefitViewModelProvider);
        final index = _tabController.index;
        if (index == 0) {
          // Se for a primeira tab ("Todos"), limpa o filtro
          ref.read(benefitViewModelProvider.notifier).filterByCategory(null);
        } else if (state.categories.isNotEmpty && index - 1 < state.categories.length) {
          // Caso contrário, filtra pela categoria correspondente
          final category = state.categories[index - 1];
          ref.read(benefitViewModelProvider.notifier).filterByCategory(category);
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Obtém o estado do ViewModel
    final state = ref.watch(benefitViewModelProvider);
    
    // Atualiza o TabController quando as categorias estiverem disponíveis
    if (state.categories.isNotEmpty && 
        (!_isTabControllerInitialized || _tabController.length != state.categories.length + 1)) {
      _updateTabController(state.categories.length + 1);
    }
    
    // Se estiver carregando, exibe indicador de carregamento
    if (state.isLoading) {
      return const Scaffold(
        body: LoadingView(message: 'Carregando benefícios...'),
      );
    }
    
    // Se houver erro, exibe mensagem de erro com opção para tentar novamente
    if (state.errorMessage != null) {
      return Scaffold(
        body: ErrorView(
          message: state.errorMessage!,
          onRetry: () => ref.read(benefitViewModelProvider.notifier).loadBenefits(),
        ),
      );
    }
    
    // Exibe a lista de benefícios
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benefícios'),
        bottom: state.categories.isNotEmpty
          ? TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                const Tab(text: 'Todos'),
                ...state.categories.map((category) => Tab(text: category)).toList(),
              ],
            )
          : null,
      ),
      body: state.benefits.isEmpty
        ? Center(
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
                  'Nenhum benefício disponível',
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Volte mais tarde para novas ofertas',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              // Exibe pontos do usuário, se disponíveis
              if (state.userPoints != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.backgroundSecondary,
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Seus pontos: ',
                      style: AppTypography.body1,
                    ),
                    Text(
                      '${state.userPoints}',
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de benefícios
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.benefits.length,
                    itemBuilder: (context, index) {
                      final benefit = state.benefits[index];
                      return BenefitCard(
                        benefit: benefit,
                        userPoints: state.userPoints,
                        onTap: () => _navigateToBenefitDetail(benefit.id),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 3),
    );
  }
  
  // Navega para a tela de detalhes do benefício
  void _navigateToBenefitDetail(String benefitId) {
    ref.read(benefitViewModelProvider.notifier).selectBenefit(benefitId);
    Navigator.pushNamed(context, '/benefits/detail');
  }
} 
