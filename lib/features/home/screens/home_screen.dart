// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/home/models/featured_content.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/home/viewmodels/featured_content_view_model.dart';
import 'package:ray_club_app/features/home/viewmodels/home_view_model.dart';
import 'package:ray_club_app/features/home/viewmodels/states/home_state.dart';
import 'package:ray_club_app/features/home/widgets/ray_club_header.dart';
import 'package:ray_club_app/features/home/widgets/register_exercise_sheet.dart';
import 'package:ray_club_app/shared/bottom_navigation_bar.dart';

// Definições simplificadas para estúdios parceiros (sem depender do Freezed)
class PartnerContent {
  final String id;
  final String title;
  final String duration;
  final String difficulty;
  final String imageUrl;
  
  const PartnerContent({
    required this.id, 
    required this.title, 
    required this.duration, 
    required this.difficulty, 
    required this.imageUrl
  });
}

class PartnerStudio {
  final String id;
  final String name;
  final String tagline;
  final Color logoColor;
  final Color backgroundColor;
  final IconData icon;
  final List<PartnerContent> contents;
  
  const PartnerStudio({
    required this.id,
    required this.name,
    required this.tagline,
    required this.logoColor,
    required this.backgroundColor,
    required this.icon,
    required this.contents,
  });
}

// Provider temporário para estúdios parceiros (simulando dados do banco)
final partnerStudiosProvider = FutureProvider<List<PartnerStudio>>((ref) async {
  // Simular um atraso para carregar os dados (como se fosse do Supabase)
  await Future.delayed(const Duration(milliseconds: 800));
  
  // Retornar dados mockados
  return [
    PartnerStudio(
      id: '1',
      name: 'Fight Fit',
      tagline: 'Funcional com luta',
      logoColor: const Color(0xFFE74C3C),
      backgroundColor: const Color(0xFFFDEDEC),
      icon: Icons.sports_mma,
      contents: [
        PartnerContent(
          id: '1',
          title: 'Fundamentos do Muay Thai',
          duration: '45 min',
          difficulty: 'Iniciante',
          imageUrl: 'https://images.pexels.com/photos/6295872/pexels-photo-6295872.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
        PartnerContent(
          id: '2',
          title: 'Boxe Funcional',
          duration: '30 min',
          difficulty: 'Intermediário',
          imageUrl: 'https://images.pexels.com/photos/4804076/pexels-photo-4804076.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
        PartnerContent(
          id: '3',
          title: 'Fight HIIT',
          duration: '25 min',
          difficulty: 'Avançado',
          imageUrl: 'https://images.pexels.com/photos/4754146/pexels-photo-4754146.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
      ],
    ),
    
    PartnerStudio(
      id: '2',
      name: 'Flow Yoga',
      tagline: 'Yoga e crioterapia',
      logoColor: const Color(0xFF3498DB),
      backgroundColor: const Color(0xFFEBF5FB),
      icon: Icons.self_improvement,
      contents: [
        PartnerContent(
          id: '4',
          title: 'Vinyasa Flow',
          duration: '50 min',
          difficulty: 'Todos os níveis',
          imageUrl: 'https://images.pexels.com/photos/6698513/pexels-photo-6698513.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
        PartnerContent(
          id: '5',
          title: 'Benefícios da Crioterapia',
          duration: '15 min',
          difficulty: 'Informativo',
          imageUrl: 'https://images.pexels.com/photos/6111616/pexels-photo-6111616.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
        PartnerContent(
          id: '6',
          title: 'Yoga para Recuperação',
          duration: '35 min',
          difficulty: 'Iniciante',
          imageUrl: 'https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
      ],
    ),
    
    PartnerStudio(
      id: '3',
      name: 'Goya Health Club',
      tagline: 'Pilates e yoga',
      logoColor: const Color(0xFF27AE60),
      backgroundColor: const Color(0xFFE9F7EF),
      icon: Icons.spa,
      contents: [
        PartnerContent(
          id: '7',
          title: 'Pilates Reformer',
          duration: '40 min',
          difficulty: 'Intermediário',
          imageUrl: 'https://images.pexels.com/photos/6551133/pexels-photo-6551133.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
        PartnerContent(
          id: '8',
          title: 'Hatha Yoga',
          duration: '60 min',
          difficulty: 'Todos os níveis',
          imageUrl: 'https://images.pexels.com/photos/4534680/pexels-photo-4534680.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
        PartnerContent(
          id: '9',
          title: 'Mat Pilates',
          duration: '30 min',
          difficulty: 'Iniciante',
          imageUrl: 'https://images.pexels.com/photos/3775593/pexels-photo-3775593.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
      ],
    ),
    
    PartnerStudio(
      id: '4',
      name: 'The Unit',
      tagline: 'Fisioterapia para treino',
      logoColor: const Color(0xFF9B59B6),
      backgroundColor: const Color(0xFFF4ECF7),
      icon: Icons.medical_services,
      contents: [
        PartnerContent(
          id: '10',
          title: 'Mobilidade para Atletas',
          duration: '25 min',
          difficulty: 'Todos os níveis',
          imageUrl: 'https://images.pexels.com/photos/8957028/pexels-photo-8957028.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
        PartnerContent(
          id: '11',
          title: 'Recuperação de Lesões',
          duration: '45 min',
          difficulty: 'Reabilitação',
          imageUrl: 'https://images.pexels.com/photos/6111609/pexels-photo-6111609.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
        PartnerContent(
          id: '12',
          title: 'Core para Performance',
          duration: '30 min',
          difficulty: 'Intermediário',
          imageUrl: 'https://images.pexels.com/photos/8436735/pexels-photo-8436735.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
      ],
    ),
  ];
});

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Key for the scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

    // Verifica se é guest
    final bool isGuest = authState.maybeWhen(
      unauthenticated: () => true, 
      orElse: () => false
    );
    
    // Nome do usuário (para personalização)
    final String username = authState.maybeWhen(
      authenticated: (user) => user.name?.split(' ')[0] ?? "Raygirl",
      orElse: () => "Raygirl"
    );

    // URL da foto do usuário (se disponível)
    final String? photoUrl = authState.maybeWhen(
      authenticated: (user) => user.photoUrl,
      orElse: () => null
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F7),
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(context, username, photoUrl, ref),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.data != null
              ? _buildHomeContent(context, username, homeState.data!)
              : _buildErrorView(context, homeState.error ?? 'Sem dados disponíveis', ref),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildDrawer(BuildContext context, String username, String? photoUrl, WidgetRef ref) {
    return Drawer(
      backgroundColor: const Color(0xFFAA9182), // Tom marrom conforme imagem de referência
      child: SafeArea(
        child: Column(
          children: [
            // Header com botão de fechar, perfil do usuário e botão de edição
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  // Botão de fechar no canto superior direito
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white, size: 28),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Foto de perfil e nome do usuário
                  Row(
                    children: [
                      // Foto de perfil
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: photoUrl != null 
                            ? NetworkImage(photoUrl) 
                            : null,
                        child: photoUrl == null
                            ? Text(
                                username.isNotEmpty ? username[0].toUpperCase() : "R",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Nome do usuário e botão de editar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi $username',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                context.router.pushNamed('/profile');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Linha de separação
            const Divider(height: 1, color: Colors.white24),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.pushNamed('/progress/day/1');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.fitness_center_outlined,
                    title: 'Treinos',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.replaceNamed('/workouts');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Nutrição',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.replaceNamed('/nutrition');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Desafio Ray 21'),
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(const ChallengesListRoute());
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.card_giftcard_outlined,
                    title: 'Benefícios',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.replaceNamed('/benefits');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.event_outlined,
                    title: 'Eventos',
                    onTap: () {
                      Navigator.of(context).pop();
                      // Adicionar rota de eventos quando disponível
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Eventos em breve!'))
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Configurações',
                    onTap: () {
                      Navigator.of(context).pop();
                      AppNavigator.navigateToSettings(context);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Ajuda',
                    onTap: () {
                      Navigator.of(context).pop();
                      AppNavigator.navigateToHelp(context);
                    },
                  ),
                ],
              ),
            ),
            
            // Botão de logout no rodapé
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();
                  
                  // Mostrar indicador de carregamento
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saindo...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  
                  // Fazer logout usando o AuthViewModel
                  await ref.read(authViewModelProvider.notifier).signOut();
                  
                  // Navegar para tela de login
                  context.router.replaceNamed('/login');
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  // Conteúdo principal da tela
  Widget _buildHomeContent(BuildContext context, String username, HomeData data) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Poderia implementar lógica para controlar progresso da rolagem, se necessário
        return false;
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header dinâmico que desaparece com a rolagem
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logos/app/novaheader.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Linha superior com menu e notificações
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                              onPressed: () {
                                if (_scaffoldKey.currentState != null) {
                                  _scaffoldKey.currentState!.openDrawer();
                                }
                              },
                            ),
                            // Espaço vazio no centro (removido o texto "RAY")
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                              onPressed: () {
                                // Navegar para notificações
                              },
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Boas-vindas ao usuário
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, $username',
                                style: const TextStyle(
                                  fontFamily: 'Stinger',
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Pronto para seu treino hoje?',
                                style: TextStyle(
                                  fontFamily: 'CenturyGothic',
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Conteúdo principal
          SliverList(
            delegate: SliverChildListDelegate([
              // NOVO: Grid de acesso rápido
              _buildQuickAccessGrid(context),
              
              // NOVO: Widget de Onboarding
              _buildOnboardingWidget(context),
              
              // NOVO: Seção de estúdios parceiros
              _buildPartnerStudiosSection(context),
              
              // Barra de progresso
              _buildProgressDashboard(context, data.progress),
              
              // Meus Treinos
              _buildMyWorkoutsSection(context),
              
              // Dicas da Ray
              _buildFeaturedContentSection(context),
              
              // Treinos populares
              _buildPopularWorkoutsSection(context, data.popularWorkouts),
              
              // Receitas populares
              _buildPopularRecipesSection(context, data.popularWorkouts),
              
              // Melhores benefícios (por último)
              _buildTopBenefitsSection(context, data.popularWorkouts),
              
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }

  // NOVO: Grid de acesso rápido
  Widget _buildQuickAccessGrid(BuildContext context) {
    // Definição das ações rápidas
    final quickActions = [
      {
        'title': 'Treinos',
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFFFF8A80), // Softer red
        'secondaryColor': const Color(0xFFFFCDD2), // Very light red
        'route': () => context.router.replaceNamed('/workouts'),
      },
      {
        'title': 'Meu Perfil',
        'icon': Icons.person_rounded,
        'color': const Color(0xFFAA9182), // Original brown (already soft)
        'secondaryColor': const Color(0xFFD7CCC8), // Very light brown
        'route': () => context.router.pushNamed('/profile'),
      },
      {
        'title': 'Desafios',
        'icon': Icons.emoji_events_rounded,
        'color': const Color(0xFFFFC069), // Softer orange
        'secondaryColor': const Color(0xFFFFE0B2), // Very light orange
        'route': () => context.router.push(const ChallengesListRoute()),
      },
      {
        'title': 'Nutrição',
        'icon': Icons.restaurant_menu_rounded,
        'color': const Color(0xFF81C784), // Softer green
        'secondaryColor': const Color(0xFFC8E6C9), // Very light green
        'route': () => context.router.replaceNamed('/nutrition'),
      },
      {
        'title': 'Benefícios',
        'icon': Icons.card_giftcard_rounded,
        'color': const Color(0xFFCE93D8), // Softer purple
        'secondaryColor': const Color(0xFFE1BEE7), // Very light purple
        'route': () => context.router.replaceNamed('/benefits'),
      },
      {
        'title': 'Eventos',
        'icon': Icons.event_rounded,
        'color': const Color(0xFF64B5F6), // Softer blue
        'secondaryColor': const Color(0xFFBBDEFB), // Very light blue
        'route': () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eventos em breve!'))
        ),
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 20), // Reduced top margin
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Explorar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          SizedBox(
            height: 90, // Reduced height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return Container(
                  width: 75,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone circular com efeito blur
                      InkWell(
                        onTap: action['route'] as Function(),
                        customBorder: const CircleBorder(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Camada mais externa com gradiente muito suave
                            Container(
                              width: 65, // Smaller size
                              height: 65, // Smaller size
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    (action['color'] as Color).withOpacity(0.5),
                                    (action['color'] as Color).withOpacity(0.0),
                                  ],
                                  stops: const [0.0, 1.0],
                                  radius: 0.7,
                                ),
                              ),
                            ),
                            // Camada intermediária com gradiente mais intenso
                            Container(
                              width: 60, // Smaller size
                              height: 60, // Smaller size
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    (action['secondaryColor'] as Color),
                                    (action['color'] as Color).withOpacity(0.7),
                                  ],
                                  stops: const [0.2, 1.0],
                                  radius: 0.8,
                                ),
                              ),
                            ),
                            // Ícone centralizado
                            Icon(
                              action['icon'] as IconData,
                              color: Colors.white,
                              size: 28, // Smaller icon
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4), // Reduced spacing
                      // Título da ação
                      Text(
                        action['title'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF555555),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // NOVO: Widget de Onboarding
  Widget _buildOnboardingWidget(BuildContext context) {
    // Lista de itens de onboarding focados no Desafio Ray de 21 dias
    final onboardingItems = [
      {
        'title': 'Regras do Desafio',
        'description': 'Conheça as regras e condições para participar do Desafio Ray de 21 dias',
        'icon': Icons.rule_folder,
        'color': const Color(0xFFFF8A80),
        'bgColor': const Color(0xFFFFEBEE),
        'action': 'Ver regras',
        'onTap': () => context.router.push(const ChallengesListRoute()),
      },
      {
        'title': 'Como Registrar Treinos',
        'description': 'Aprenda a registrar seus treinos diários para validar sua participação no desafio',
        'icon': Icons.fitness_center,
        'color': const Color(0xFF81C784),
        'bgColor': const Color(0xFFE8F5E9),
        'action': 'Saiba como',
        'onTap': () => context.router.push(const ChallengesListRoute()),
      },
      {
        'title': 'Processo de Verificação',
        'description': 'Entenda como os treinos são verificados e aprovados no sistema do Desafio Ray',
        'icon': Icons.verified,
        'color': const Color(0xFFFFC069),
        'bgColor': const Color(0xFFFFF8E1),
        'action': 'Ver detalhes',
        'onTap': () => context.router.push(const ChallengesListRoute()),
      },
      {
        'title': 'Prêmios e Classificação',
        'description': 'Descubra como funciona o sistema de pontos, classificação e prêmios do desafio',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFCE93D8),
        'bgColor': const Color(0xFFF3E5F5),
        'action': 'Ver prêmios',
        'onTap': () => context.router.push(const ChallengesListRoute()),
      },
    ];

    // Controller para PageView
    final PageController pageController = PageController(viewportFraction: 0.93);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            children: const [
              Text(
                'Desafio ',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                'Ray 21 Dias',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFBF8F5C), // Tom marrom dourado para destacar
                ),
              ),
            ],
          ),
        ),
        
        // Carrossel unificado com banner principal e cards informativos
        SizedBox(
          height: 230, // Aumentado para dar mais destaque
          child: PageView.builder(
            controller: pageController,
            itemCount: onboardingItems.length + 1, // +1 para o banner principal
            itemBuilder: (context, index) {
              // Primeiro item é o banner principal
              if (index == 0) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.router.push(const ChallengesListRoute()),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Imagem de fundo
                            Image.asset(
                              'assets/images/logos/app/Ray Club-30.png',
                              fit: BoxFit.cover,
                            ),
                            
                            // Overlay de gradiente para legibilidade
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Badge 21 DIAS no canto
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Text(
                                  '21 DIAS',
                                  style: TextStyle(
                                    color: Color(0xFFBF8F5C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Texto principal movido para o topo
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 20,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Texto principal em duas linhas
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'BEM VINDO AO',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'DESAFIO RAY',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Stinger',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Subtítulo separado no meio do card
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 80, // Posicionado em relação ao fundo, acima do botão
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Sua jornada de bem estar começa aqui!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Botão de ação separado na parte inferior
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 24,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () => context.router.push(const ChallengesListRoute()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFBF8F5C),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'SAIBA MAIS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              // Restante dos itens são os cards informativos
              final item = onboardingItems[index - 1]; // -1 porque o índice 0 é o banner principal
              return Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: item['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logos/app/Ray Club-25.png'),
                    fit: BoxFit.cover,
                    opacity: 0.15,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Ícone lado esquerdo
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Conteúdo lado direito
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['description'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: item['onTap'] as Function(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: item['color'] as Color,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: const Size(100, 36),
                              ),
                              child: Text(
                                item['action'] as String,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Indicador de página
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Center(
            child: SmoothPageIndicator(
              controller: pageController,
              count: onboardingItems.length + 1, // +1 para o banner principal
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 8,
                radius: 4,
                dotColor: Colors.grey.shade300,
                activeDotColor: const Color(0xFFBF8F5C),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Dashboard de progresso com calendário semanal
  Widget _buildProgressDashboard(BuildContext context, UserProgress progress) {
    // Lista de dias da semana abreviados
    final dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    
    // Dia atual (0 = segunda, 6 = domingo)
    final currentDay = DateTime.now().weekday - 1; // -1 porque weekday começa em 1 (segunda)
    
    // Simulação de dias treinados na semana (em um app real, viria do modelo progress)
    final List<bool> trainedDays = [true, false, true, false, false, true, false]; // Exemplo
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE78639),  // Laranja principal da Ray
            Color(0xFFFFB176),  // Laranja mais claro
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título e badge de desafio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e descrição
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Daily ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'challenge',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Do your plan before 07:00 AM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Indicador de participantes
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Text('M', style: TextStyle(color: AppColors.brown, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    Transform.translate(
                      offset: Offset(-5, 0),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: Text('J', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-10, 0),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: Text('A', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Calendário semanal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final bool isToday = index == currentDay;
              final bool hasTrained = trainedDays[index];
              
              return InkWell(
                onTap: () {
                  // Navegação para tela de detalhes do dia
                  AppNavigator.navigateToProgressDay(context, index + 1);
                },
                child: Column(
                  children: [
                    // Dia da semana
                    Text(
                      dayLabels[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Círculo do dia
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasTrained 
                            ? (isToday ? Colors.white : Colors.white.withOpacity(0.8))
                            : (isToday ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.15)),
                        border: isToday 
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: isToday ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: Text(
                          (index + 22).toString(), // Simulando dias do mês (22-28)
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hasTrained 
                                ? (isToday ? AppColors.brown : AppColors.brown)
                                : (isToday ? AppColors.brown : Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 20),
          
          // Estatísticas de progresso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat(
                'Dias treinados', 
                progress.daysTrainedThisMonth.toString(),
                Icons.calendar_today,
                Colors.white,
              ),
              _buildProgressStat(
                'Sequência atual', 
                progress.currentStreak.toString(),
                Icons.local_fire_department,
                Colors.white,
              ),
              _buildProgressStat(
                'Melhor sequência', 
                progress.bestStreak.toString(),
                Icons.emoji_events,
                Colors.white,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botão "Seu plano" para navegar até o plano completo
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print("DEBUG: Trying to navigate to progress day screen");
                context.router.pushNamed('/progress/day/1');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your plan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Item de estatística de progresso para o novo dashboard
  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Treinos populares redesenhados
  Widget _buildPopularWorkoutsSection(BuildContext context, List<PopularWorkout> workouts) {
    // Lista mockada de treinos populares para garantir exibição mesmo quando não há dados
    final mockWorkouts = [
      {
        'id': 'workout1',
        'title': 'Treino Full Body',
        'imageUrl': 'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=800',
        'duration': '45 min',
        'difficulty': 'Intermediário',
        'favoriteCount': 245
      },
      {
        'id': 'workout2',
        'title': 'Abdômen Definido',
        'imageUrl': 'https://images.pexels.com/photos/4162452/pexels-photo-4162452.jpeg?auto=compress&cs=tinysrgb&w=800',
        'duration': '20 min',
        'difficulty': 'Iniciante',
        'favoriteCount': 189
      },
      {
        'id': 'workout3',
        'title': 'Cardio Intenso',
        'imageUrl': 'https://images.pexels.com/photos/3764013/pexels-photo-3764013.jpeg?auto=compress&cs=tinysrgb&w=800',
        'duration': '30 min',
        'difficulty': 'Avançado',
        'favoriteCount': 136
      },
      {
        'id': 'workout4',
        'title': 'Treino de Pernas',
        'imageUrl': 'https://images.pexels.com/photos/136404/pexels-photo-136404.jpeg?auto=compress&cs=tinysrgb&w=800',
        'duration': '35 min',
        'difficulty': 'Intermediário',
        'favoriteCount': 98
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Treinos Populares',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ver Todos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockWorkouts.length,
              itemBuilder: (context, index) {
                final workout = mockWorkouts[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Imagem de fundo
                      Positioned.fill(
                        child: Image.network(
                          workout['imageUrl'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.primary.withOpacity(0.2),
                            child: Center(
                              child: Icon(
                                Icons.fitness_center,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Gradiente para melhorar legibilidade
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Conteúdo
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                workout['difficulty'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              workout['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  workout['duration'] as String,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (workout['favoriteCount'] as int).toString(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Botão de Material que cobre todo o card
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navegar para o detalhe do treino específico na aba de treinos
                              context.router.pushNamed('/workouts/detail/${workout['id']}');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Receitas populares
  Widget _buildPopularRecipesSection(BuildContext context, List<PopularWorkout> workouts) {
    // Lista temporária de receitas mockadas
    final mockRecipes = [
      {
        'id': 'recipe1',
        'title': 'Smoothie Proteico',
        'imageUrl': 'https://images.pexels.com/photos/775031/pexels-photo-775031.jpeg?auto=compress&cs=tinysrgb&w=800',
        'prepTime': '10',
        'calories': 320,
        'likes': 124
      },
      {
        'id': 'recipe2',
        'title': 'Salada Fitness',
        'imageUrl': 'https://images.pexels.com/photos/1059905/pexels-photo-1059905.jpeg?auto=compress&cs=tinysrgb&w=800',
        'prepTime': '15',
        'calories': 280,
        'likes': 98
      },
      {
        'id': 'recipe3',
        'title': 'Bowl de Açaí',
        'imageUrl': 'https://images.pexels.com/photos/1092730/pexels-photo-1092730.jpeg?auto=compress&cs=tinysrgb&w=800',
        'prepTime': '8',
        'calories': 340,
        'likes': 145
      },
      {
        'id': 'recipe4',
        'title': 'Panqueca Proteica',
        'imageUrl': 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=800',
        'prepTime': '20',
        'calories': 410,
        'likes': 87
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Receitas Populares',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ver Todas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockRecipes.length,
              itemBuilder: (context, index) {
                final recipe = mockRecipes[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Imagem de fundo
                      Positioned.fill(
                        child: Image.network(
                          recipe['imageUrl'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.green.withOpacity(0.2),
                          ),
                        ),
                      ),
                      
                      // Gradiente para melhorar legibilidade
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Conteúdo
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${recipe['prepTime']} min",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recipe['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.restaurant,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${recipe['calories']} kcal",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.thumb_up,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${recipe['likes']}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Botão de Material que cobre todo o card
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navegar para o detalhe da receita específica na aba de nutrição
                              context.router.pushNamed('/nutrition/recipe/${recipe['id']}');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Melhores benefícios
  Widget _buildTopBenefitsSection(BuildContext context, List<PopularWorkout> workouts) {
    // Lista temporária de benefícios mockados
    final mockBenefits = [
      {
        'id': 'benefit1',
        'title': 'Desconto Academia',
        'imageUrl': 'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=800',
        'partner': 'SmartFit',
        'discount': '30%',
        'validUntil': '31/05/2023'
      },
      {
        'id': 'benefit2',
        'title': 'Suplementos Fitness',
        'imageUrl': 'https://images.pexels.com/photos/3735635/pexels-photo-3735635.jpeg?auto=compress&cs=tinysrgb&w=800',
        'partner': 'Growth Supps',
        'discount': '15%',
        'validUntil': '15/05/2023'
      },
      {
        'id': 'benefit3',
        'title': 'Consulta Nutricional',
        'imageUrl': 'https://images.pexels.com/photos/8844383/pexels-photo-8844383.jpeg?auto=compress&cs=tinysrgb&w=800',
        'partner': 'NutriClub',
        'discount': '50%',
        'validUntil': '20/05/2023'
      },
      {
        'id': 'benefit4',
        'title': 'Roupas Esportivas',
        'imageUrl': 'https://images.pexels.com/photos/6787202/pexels-photo-6787202.jpeg?auto=compress&cs=tinysrgb&w=800',
        'partner': 'SportWear',
        'discount': '25%',
        'validUntil': '10/05/2023'
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Melhores Benefícios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegação para a tela de todos os benefícios
                  context.router.pushNamed('/benefits');
                },
                child: Text(
                  'Ver Todos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockBenefits.length,
              itemBuilder: (context, index) {
                final benefit = mockBenefits[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Imagem de fundo
                      Positioned.fill(
                        child: Image.network(
                          benefit['imageUrl'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.purple.withOpacity(0.2),
                          ),
                        ),
                      ),
                      
                      // Gradiente para melhorar legibilidade
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Conteúdo
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Desconto ${benefit['discount']}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              benefit['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.store,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  benefit['partner'] as String,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.event_available,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    "Válido até ${benefit['validUntil']}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Botão de Material que cobre todo o card
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navegar para o detalhe do benefício específico na aba de benefícios
                              context.router.pushNamed('/benefits/detail/${benefit['id']}');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Seção de conteúdos em destaque redesenhada
  Widget _buildFeaturedContentSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final featuredState = ref.watch(featuredContentViewModelProvider);
        
        // Estilos para exibição de erro ou carregamento
        if (featuredState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (featuredState.error != null) {
          return Center(child: Text('Erro: ${featuredState.error}'));
        }
        
        // Lista de dicas criativas para o bem-estar (temporário até implementação real)
        final List<FeaturedContent> rayTips = [
          FeaturedContent(
            id: "tip1",
            title: "Hidratação Criativa",
            description: "Adicione frutas congeladas à sua água para manter-se hidratado(a) com mais sabor e menos calorias!",
            category: ContentCategory(
              id: 'wellness',
              name: 'Bem-estar',
              color: Colors.blue,
            ),
            imageUrl: "https://images.pexels.com/photos/1382393/pexels-photo-1382393.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.water_drop,
          ),
          FeaturedContent(
            id: "tip2",
            title: "Treino HIIT de 7 minutos",
            description: "Um treino rápido e intenso perfeito para dias ocupados. 7 exercícios, 30 segundos cada, resultados impressionantes!",
            category: ContentCategory(
              id: 'workout',
              name: 'Treino',
              color: AppColors.primary,
            ),
            imageUrl: "https://images.pexels.com/photos/2294361/pexels-photo-2294361.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.timer,
          ),
          FeaturedContent(
            id: "tip3",
            title: "Receita: Smoothie Energético",
            description: "Banana + espinafre + proteína + aveia = o combustível perfeito para seu corpo antes do treino!",
            category: ContentCategory(
              id: 'nutrition',
              name: 'Nutrição',
              color: Colors.green,
            ),
            imageUrl: "https://images.pexels.com/photos/3323682/pexels-photo-3323682.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.blender,
          ),
          FeaturedContent(
            id: "tip4",
            title: "3 Alongamentos para Alívio Imediato",
            description: "Experimente estes alongamentos para aliviar tensão no pescoço e ombros após horas no computador.",
            category: ContentCategory(
              id: 'wellness',
              name: 'Bem-estar',
              color: Colors.blue,
            ),
            imageUrl: "https://images.pexels.com/photos/4056535/pexels-photo-4056535.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.self_improvement,
          ),
          FeaturedContent(
            id: "tip5",
            title: "Festival Ray de Verão",
            description: "Prepare-se para nosso próximo evento ao ar livre com aulas coletivas, desafios e muitos prêmios!",
            category: ContentCategory(
              id: 'event',
              name: 'Evento',
              color: Colors.orange,
            ),
            imageUrl: "https://images.pexels.com/photos/2836486/pexels-photo-2836486.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.event,
          ),
          FeaturedContent(
            id: "tip6",
            title: "Desconto Exclusivo: Academia Parceira",
            description: "Membros Ray Club têm 25% de desconto na rede Fitness Plus durante este mês!",
            category: ContentCategory(
              id: 'benefit',
              name: 'Benefício',
              color: Colors.purple,
            ),
            imageUrl: "https://images.pexels.com/photos/949126/pexels-photo-949126.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.card_giftcard,
          ),
          // Novas dicas adicionais
          FeaturedContent(
            id: "tip7",
            title: "Meditação em 5 Minutos",
            description: "Técnica de respiração 4-7-8: inspire por 4 segundos, segure por 7 e expire por 8. Reduza o estresse instantaneamente!",
            category: ContentCategory(
              id: 'wellness',
              name: 'Bem-estar',
              color: Colors.blue,
            ),
            imageUrl: "https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.spa,
          ),
          FeaturedContent(
            id: "tip8",
            title: "Treino de Escada: Queima Total",
            description: "Transforme qualquer escada em um treino completo. Alternando entre subir correndo e agachamentos, desafie seu corpo!",
            category: ContentCategory(
              id: 'workout',
              name: 'Treino',
              color: AppColors.primary,
            ),
            imageUrl: "https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.trending_up,
          ),
          FeaturedContent(
            id: "tip9",
            title: "Receita: Panquecas Proteicas",
            description: "2 ovos + 1 banana + 30g de aveia = panquecas saudáveis e deliciosas com mais de 15g de proteína!",
            category: ContentCategory(
              id: 'nutrition',
              name: 'Nutrição',
              color: Colors.green,
            ),
            imageUrl: "https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.breakfast_dining,
          ),
          FeaturedContent(
            id: "tip10",
            title: "Postura Perfeita no Home Office",
            description: "Ombros relaxados, monitor na altura dos olhos e pés apoiados. Seu corpo vai agradecer depois de um dia de trabalho!",
            category: ContentCategory(
              id: 'wellness',
              name: 'Bem-estar',
              color: Colors.blue,
            ),
            imageUrl: "https://images.pexels.com/photos/4050315/pexels-photo-4050315.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.chair,
          ),
          FeaturedContent(
            id: "tip11",
            title: "Workshop: Nutrição Intuitiva",
            description: "Participe do nosso workshop online e aprenda a ouvir os sinais do seu corpo para uma relação saudável com a comida.",
            category: ContentCategory(
              id: 'event',
              name: 'Evento',
              color: Colors.orange,
            ),
            imageUrl: "https://images.pexels.com/photos/8941995/pexels-photo-8941995.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.health_and_safety,
          ),
          FeaturedContent(
            id: "tip12",
            title: "Sessão de Massagem com Desconto",
            description: "Membros Ray Club recebem 30% off em sessões de massagem terapêutica no Spa Equilíbrio. Reserve já!",
            category: ContentCategory(
              id: 'benefit',
              name: 'Benefício',
              color: Colors.purple,
            ),
            imageUrl: "https://images.pexels.com/photos/3997989/pexels-photo-3997989.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.spa,
          ),
          FeaturedContent(
            id: "tip13",
            title: "Desafio: 30 Dias de Yoga",
            description: "Comece hoje nosso desafio de yoga e transforme seu corpo e mente em apenas um mês. Acessível para todos os níveis!",
            category: ContentCategory(
              id: 'workout',
              name: 'Treino',
              color: AppColors.primary,
            ),
            imageUrl: "https://images.pexels.com/photos/3823039/pexels-photo-3823039.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.self_improvement,
          ),
          FeaturedContent(
            id: "tip14",
            title: "Lanches Saudáveis no Trabalho",
            description: "Prepare mix de nozes, palitos de legumes e húmus para manter a energia alta durante todo o dia de trabalho.",
            category: ContentCategory(
              id: 'nutrition',
              name: 'Nutrição',
              color: Colors.green,
            ),
            imageUrl: "https://images.pexels.com/photos/1092730/pexels-photo-1092730.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.lunch_dining,
          ),
          FeaturedContent(
            id: "tip15",
            title: "Cuidados com a Pele Pós-Treino",
            description: "Sempre lave o rosto logo após o treino e aplique hidratante não comedogênico para evitar acne e irritações.",
            category: ContentCategory(
              id: 'wellness',
              name: 'Bem-estar',
              color: Colors.blue,
            ),
            imageUrl: "https://images.pexels.com/photos/3738349/pexels-photo-3738349.jpeg?auto=compress&cs=tinysrgb&w=800",
            icon: Icons.face,
          ),
        ];
        
        // Exibe a lista de dicas da Ray
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Dicas da ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        'Ray',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Ver Todas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Lista de dicas da Ray
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: rayTips.length,
                  itemBuilder: (context, index) {
                    final content = rayTips[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Navegação para detalhes do conteúdo
                            Navigator.pushNamed(
                              context, 
                              '/featured-content-detail',
                              arguments: content.id,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Imagem
                              Container(
                                width: double.infinity,
                                height: 140,
                                decoration: BoxDecoration(
                                  image: content.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(content.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                  color: content.imageUrl == null ? Colors.grey[300] : null,
                                ),
                                child: content.imageUrl == null
                                  ? Icon(
                                      content.icon,
                                      size: 40,
                                      color: Colors.grey[600],
                                    )
                                  : null,
                              ),
                              
                              // Conteúdo de texto
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Tipo de conteúdo (badge)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(content.category).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getCategoryName(content.category),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _getCategoryColor(content.category),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Título
                                    Text(
                                      content.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333333),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    
                                    // Subtítulo
                                    Text(
                                      content.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF777777),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Função auxiliar para obter cores por categoria
  Color _getCategoryColor(ContentCategory category) {
    return category.color ?? AppColors.primary;
  }
  
  // Função auxiliar para obter nomes por categoria
  String _getCategoryName(ContentCategory category) {
    return category.name;
  }

  // Meus Treinos
  Widget _buildMyWorkoutsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meus Treinos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegação para a tela de histórico de treinos
                  context.router.pushNamed(AppRoutes.workoutHistory);
                },
                child: Text(
                  'Ver Histórico',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Placeholder for workout image
                      Positioned.fill(
                        child: Container(
                          color: Colors.grey[300],
                        ),
                      ),
                      
                      // Gradiente para melhorar legibilidade
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Conteúdo
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Treino',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Título do Treino',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '30 minutos',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Botão de Material que cobre todo o card
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navegar para o histórico de treinos
                              context.router.pushNamed(AppRoutes.workoutHistory);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói uma visualização amigável para erros
  Widget _buildErrorView(BuildContext context, String errorMessage, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.amber.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Não conseguimos carregar os dados neste momento.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (kDebugMode) ... [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(homeViewModelProvider.notifier).loadHomeData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Redirecionar para treinos ou outra tela
                context.router.replaceNamed('/workouts');
              },
              child: const Text('Ver Treinos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String errorMessage, WidgetRef ref) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.red.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, _) => TextButton(
                  onPressed: () {
                    ref.read(homeViewModelProvider.notifier).loadHomeData();
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NOVO: Seção de estúdios parceiros
  Widget _buildPartnerStudiosSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final partnerStudiosAsync = ref.watch(partnerStudiosProvider);
        
        return partnerStudiosAsync.when(
          data: (studios) {
            if (studios.isEmpty) {
              return const SizedBox.shrink(); // Não mostrar nada se não houver estúdios
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título da seção
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.handshake_outlined,
                        size: 24,
                        color: Color(0xFFE78639),
                      ),
                      const SizedBox(width: 10),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              AppColors.brown,
                              Color(0xFFEE583F),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Parceiros',
                          style: TextStyle(
                            fontFamily: 'Stinger',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brown.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            fontFamily: 'Stinger',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE78639),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Listagem dos estúdios parceiros com seus conteúdos
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: studios.length,
                  itemBuilder: (context, index) {
                    final studio = studios[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header do estúdio parceiro
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            decoration: BoxDecoration(
                              color: studio.backgroundColor ?? const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: (studio.logoColor ?? Colors.grey).withOpacity(0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Ícone/logo do estúdio
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (studio.logoColor ?? Colors.grey).withOpacity(0.15),
                                  ),
                                  child: Icon(
                                    studio.icon ?? Icons.fitness_center,
                                    color: studio.logoColor ?? Colors.grey,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                // Informações do estúdio
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studio.name,
                                        style: TextStyle(
                                          fontFamily: 'Stinger',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: studio.logoColor ?? Colors.grey,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        studio.tagline,
                                        style: const TextStyle(
                                          fontFamily: 'CenturyGothic',
                                          fontSize: 14,
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Botão para ver todos
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Ver Todos',
                                        style: TextStyle(
                                          fontFamily: 'CenturyGothic',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: studio.logoColor ?? Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 10,
                                        color: studio.logoColor ?? Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Conteúdos do estúdio em cards horizontais (se houver)
                        if (studio.contents.isNotEmpty)
                          SizedBox(
                            height: 210,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 0, 16, 24),
                              scrollDirection: Axis.horizontal,
                              itemCount: studio.contents.length,
                              itemBuilder: (context, contentIndex) {
                                final content = studio.contents[contentIndex];
                                return Container(
                                  width: 165,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      // Imagem de fundo
                                      Positioned.fill(
                                        child: Image.network(
                                          content.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: (studio.logoColor ?? Colors.grey).withOpacity(0.1),
                                            child: Center(
                                              child: Icon(
                                                studio.icon ?? Icons.fitness_center,
                                                color: studio.logoColor ?? Colors.grey,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Gradiente para legibilidade
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.75),
                                              ],
                                              stops: const [0.6, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Badge do parceiro no canto superior
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: studio.logoColor ?? Colors.grey,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            studio.name,
                                            style: const TextStyle(
                                              fontFamily: 'CenturyGothic',
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Conteúdo de texto
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                content.title,
                                                style: const TextStyle(
                                                  fontFamily: 'CenturyGothic',
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.access_time,
                                                    color: Colors.white70,
                                                    size: 12,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    content.duration,
                                                    style: const TextStyle(
                                                      fontFamily: 'CenturyGothic',
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    height: 3,
                                                    width: 3,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white30,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      content.difficulty,
                                                      style: const TextStyle(
                                                        fontFamily: 'CenturyGothic',
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      
                                      // Área clicável
                                      Positioned.fill(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              // Implementar navegação para o conteúdo específico
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Abrindo ${content.title}'),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        
                        // Separador
                        if (index < studios.length - 1)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(40, 0, 40, 16),
                            child: Divider(
                              color: Colors.grey.withOpacity(0.2),
                              height: 1,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar estúdios parceiros:\n${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(partnerStudiosProvider),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}












