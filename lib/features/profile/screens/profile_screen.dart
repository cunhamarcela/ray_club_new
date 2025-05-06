// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/widgets/accessible_widget.dart';

// Project imports:
import '../../../core/theme/app_theme.dart';
import '../../../shared/bottom_navigation_bar.dart';
import '../models/profile_model.dart';
import '../viewmodels/profile_view_model.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/core/constants/privacy_policy.dart';
import 'package:ray_club_app/features/profile/screens/privacy_policy_screen.dart';
import 'package:ray_club_app/features/profile/screens/consent_management_screen.dart';

@RoutePage()
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).loadCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.errorMessage != null
              ? Center(child: Text('Erro: ${profileState.errorMessage}'))
              : profileState.profile != null
                  ? _buildProfileContent(context, profileState.profile!)
                  : const Center(child: Text('Perfil não encontrado')),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildProfileContent(BuildContext context, Profile profile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header com foto e informações básicas
          _buildProfileHeader(context, profile),
          
          // Estatísticas
          _buildStatisticsSection(context, profile),
          
          // Metas
          _buildGoalsSection(context),
          
          // Configurações e Privacidade
          _buildSettingsSection(context),
          
          // Botão Logout
          _buildLogoutButton(context),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Profile profile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF29B6F6),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Avatar
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    profile.name?.isNotEmpty == true ? profile.name![0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF29B6F6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Nome
              Text(
                profile.name ?? 'Usuário',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Email
              Text(
                profile.email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Botão editar perfil
              ElevatedButton(
                onPressed: () {
                  // Navegação para edição de perfil
                  context.router.pushNamed('/profile/edit');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF29B6F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).withAccessibility(
                label: 'Botão para editar perfil',
                isButton: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, Profile profile) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ).withAccessibility(
            label: 'Título da seção de estatísticas',
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                value: profile.completedWorkouts.toString(),
                label: 'Treinos',
                icon: Icons.fitness_center,
                color: const Color(0xFF4CAF50),
              ),
              _buildProfileMenuItem(
                context: context,
                iconData: Icons.emoji_events,
                label: 'Desafio Ray 21',
                onTap: () => AppNavigator.navigateToChallenges(context),
              ),
              _buildStatItem(
                value: profile.streak.toString(),
                label: 'Dias Ativos',
                icon: Icons.calendar_today,
                color: const Color(0xFF2196F3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF777777),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection(BuildContext context) {
    final profile = ref.watch(profileViewModelProvider).profile;
    if (profile == null) return const SizedBox();
    
    // Converter as metas salvas no formato esperado pelo UI
    List<Map<String, dynamic>> goals = [];
    
    for (final goalText in profile.goals) {
      Map<String, dynamic> goal = {};
      
      // Verificar se a meta já tem metadados
      if (goalText.contains('|current:')) {
        final parts = goalText.split('|');
        final title = parts[0];
        
        // Extrair metadados
        double current = 0;
        double target = 1;
        String unit = '';
        
        for (int i = 1; i < parts.length; i++) {
          final metaPart = parts[i];
          if (metaPart.startsWith('current:')) {
            current = double.tryParse(metaPart.substring(8)) ?? 0;
          } else if (metaPart.startsWith('target:')) {
            target = double.tryParse(metaPart.substring(7)) ?? 1;
          } else if (metaPart.startsWith('unit:')) {
            unit = metaPart.substring(5);
          }
        }
        
        // Determinar cor e ícone baseado no título
        IconData icon = Icons.flag;
        Color color = const Color(0xFF00897B);
        
        if (title.contains('Treinar')) {
          icon = Icons.fitness_center;
          color = const Color(0xFF4CAF50);
        } else if (title.contains('Perder')) {
          icon = Icons.monitor_weight;
          color = const Color(0xFFE53935);
        } else if (title.contains('Ganhar')) {
          icon = Icons.fitness_center;
          color = const Color(0xFF1E88E5);
        } else if (title.contains('Correr')) {
          icon = Icons.directions_run;
          color = const Color(0xFFFF9800);
        } else if (title.contains('Alongar')) {
          icon = Icons.self_improvement;
          color = const Color(0xFF9C27B0);
        }
        
        goal = {
          'title': title,
          'current': current,
          'target': target,
          'unit': unit,
          'icon': icon,
          'color': color,
        };
      } else if (goalText.contains('Treinar')) {
        // Formato antigo: "Treinar 5x por semana"
        final parts = goalText.split(' ');
        final target = int.tryParse(parts[1].replaceAll('x', '')) ?? 5;
        goal = {
          'title': goalText,
          'current': 3, // Valor fixo para demo
          'target': target,
          'unit': 'dias',
          'icon': Icons.fitness_center,
          'color': const Color(0xFF4CAF50),
        };
      } else if (goalText.contains('Perder')) {
        // Formato antigo: "Perder 5kg"
        final parts = goalText.split(' ');
        final target = double.tryParse(parts[1].replaceAll('kg', '')) ?? 5;
        goal = {
          'title': goalText,
          'current': target / 2, // Valor fixo para demo
          'target': target,
          'unit': 'kg',
          'icon': Icons.monitor_weight,
          'color': const Color(0xFFE53935),
        };
      } else if (goalText.contains('Ganhar')) {
        // Formato antigo: "Ganhar 5kg de massa muscular"
        final parts = goalText.split(' ');
        final target = double.tryParse(parts[1].replaceAll('kg', '')) ?? 5;
        goal = {
          'title': goalText,
          'current': target / 3, // Valor fixo para demo
          'target': target,
          'unit': 'kg',
          'icon': Icons.fitness_center,
          'color': const Color(0xFF1E88E5),
        };
      } else if (goalText.contains('Correr')) {
        // Formato antigo: "Correr 10km por semana"
        final parts = goalText.split(' ');
        final target = double.tryParse(parts[1].replaceAll('km', '')) ?? 10;
        goal = {
          'title': goalText,
          'current': target / 2, // Valor fixo para demo
          'target': target,
          'unit': 'km',
          'icon': Icons.directions_run,
          'color': const Color(0xFFFF9800),
        };
      } else if (goalText.contains('Alongar')) {
        // Formato antigo: "Alongar 20 minutos por dia"
        final parts = goalText.split(' ');
        final target = int.tryParse(parts[1]) ?? 20;
        goal = {
          'title': goalText,
          'current': target / 2, // Valor fixo para demo
          'target': target,
          'unit': 'min',
          'icon': Icons.self_improvement,
          'color': const Color(0xFF9C27B0),
        };
      } else {
        // Outros tipos de meta
        goal = {
          'title': goalText,
          'current': 1,
          'target': 1,
          'unit': '',
          'icon': Icons.flag,
          'color': const Color(0xFF00897B),
        };
      }
      
      goals.add(goal);
    }
    
    // Se não houver metas, mostrar mensagem
    if (goals.isEmpty) {
      goals = []; // Limpar para não mostrar nada
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minhas Metas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  // Adicionar nova meta
                  final result = await AppNavigator.navigateToGoalForm(context);
                  if (result == true) {
                    // Recarregar perfil quando retornar
                    if (mounted) {
                      ref.read(profileViewModelProvider.notifier).loadCurrentUserProfile();
                    }
                  }
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Adicionar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF29B6F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (goals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Adicione metas para acompanhar seu progresso',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 16,
                  ),
                ),
              ),
            ).withAccessibility(
              hint: 'Você ainda não adicionou metas para acompanhar seu progresso',
            )
          else
            ...goals.map((goal) => _buildGoalItem(context, goal)).toList(),
        ],
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, Map<String, dynamic> goal) {
    final progress = goal['current'] / goal['target'];
    final percentage = (progress * 100).round();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: goal['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    goal['icon'],
                    color: goal['color'],
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF777777),
                        ),
                        children: [
                          TextSpan(
                            text: '${goal['current']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: goal['color'],
                            ),
                          ),
                          const TextSpan(text: ' de '),
                          TextSpan(text: '${goal['target']} ${goal['unit']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: goal['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(goal['color']),
              minHeight: 10,
            ),
          ),
          
          // Adicionar controles de progresso
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: goal['color'],
                  onPressed: () {
                    // Decrementar progresso
                    _updateGoalProgress(goal, goal['current'] - 0.5);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: goal['color'],
                  onPressed: () {
                    // Incrementar progresso
                    _updateGoalProgress(goal, goal['current'] + 0.5);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Método para atualizar o progresso da meta
  void _updateGoalProgress(Map<String, dynamic> goal, double newProgress) async {
    // Verificar limites
    if (newProgress < 0) newProgress = 0;
    if (newProgress > goal['target']) newProgress = goal['target'];
    
    final profile = ref.read(profileViewModelProvider).profile;
    if (profile == null) return;
    
    final titleToSearch = goal['title'];
    
    // Criar novas metas com formato atualizado para armazenar o progresso
    List<String> updatedGoals = [];
    
    for (final goalText in profile.goals) {
      if (goalText.contains(titleToSearch)) {
        // Extrair informações da meta para reconstruí-la com o novo progresso
        String updatedGoalText;
        if (goalText.contains('Treinar')) {
          // Formato: "Treinar 5x por semana"
          final parts = goalText.split(' ');
          final target = int.tryParse(parts[1].replaceAll('x', '')) ?? 5;
          updatedGoalText = 'Treinar ${parts[1]} por semana|current:$newProgress|target:$target|unit:dias';
        } else if (goalText.contains('Perder')) {
          // Formato: "Perder 5kg"
          final parts = goalText.split(' ');
          final target = double.tryParse(parts[1].replaceAll('kg', '')) ?? 5;
          updatedGoalText = 'Perder ${parts[1]}|current:$newProgress|target:$target|unit:kg';
        } else if (goalText.contains('Ganhar')) {
          // Formato: "Ganhar 5kg de massa muscular"
          final parts = goalText.split(' ');
          final target = double.tryParse(parts[1].replaceAll('kg', '')) ?? 5;
          updatedGoalText = 'Ganhar ${parts[1]} de massa muscular|current:$newProgress|target:$target|unit:kg';
        } else if (goalText.contains('Correr')) {
          // Formato: "Correr 10km por semana"
          final parts = goalText.split(' ');
          final target = double.tryParse(parts[1].replaceAll('km', '')) ?? 10;
          updatedGoalText = 'Correr ${parts[1]} por semana|current:$newProgress|target:$target|unit:km';
        } else if (goalText.contains('Alongar')) {
          // Formato: "Alongar 20 minutos por dia"
          final parts = goalText.split(' ');
          final target = int.tryParse(parts[1]) ?? 20;
          updatedGoalText = 'Alongar ${parts[1]} minutos por dia|current:$newProgress|target:$target|unit:min';
        } else {
          // Para outros tipos, apenas anexar o progresso
          updatedGoalText = '$goalText|current:$newProgress|target:1|unit:';
        }
        
        updatedGoals.add(updatedGoalText);
      } else {
        // Se já tem um formato estruturado, mantém como está
        if (goalText.contains('|current:')) {
          updatedGoals.add(goalText);
        } else {
          // Para metas antigas que não têm metadados, adiciona valores padrão
          updatedGoals.add('$goalText|current:0|target:1|unit:');
        }
      }
    }
    
    // Atualizar o perfil com as novas metas
    await ref.read(profileViewModelProvider.notifier).updateProfile(goals: updatedGoals);
    
    // Recarregar o perfil para mostrar as mudanças
    await ref.read(profileViewModelProvider.notifier).loadCurrentUserProfile();
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            'Configurações e Privacidade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          
          // Política de Privacidade
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF29B6F6)),
            title: const Text('Política de Privacidade'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              AppNavigator.navigateToPrivacyPolicy(context);
            },
          ).withAccessibility(
            label: 'Link para Política de Privacidade',
            hint: 'Toque para ver a política de privacidade completa',
            isButton: true,
          ),
          
          const Divider(),
          
          // Gerenciamento de Consentimentos GDPR/LGPD
          ListTile(
            leading: const Icon(Icons.security_outlined, color: Color(0xFF29B6F6)),
            title: const Text('Gerenciar Consentimentos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              AppNavigator.navigateToConsentManagement(context);
            },
          ).withAccessibility(
            label: 'Link para Gerenciamento de Consentimentos',
            hint: 'Toque para gerenciar suas permissões e consentimentos de privacidade',
            isButton: true,
          ),
          
          const Divider(),
          
          // Termos de Uso
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Color(0xFF29B6F6)),
            title: const Text('Termos de Uso'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              AppNavigator.navigateToTermsOfUse(context);
            },
          ).withAccessibility(
            label: 'Link para Termos de Uso',
            hint: 'Toque para ver os termos de uso completos',
            isButton: true,
          ),
          
          const Divider(),
          
          // Notificações
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: Color(0xFF29B6F6)),
            title: const Text('Configurar Notificações'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              AppNavigator.navigateToNotificationSettings(context);
            },
          ).withAccessibility(
            label: 'Link para Configurações de Notificações',
            hint: 'Toque para gerenciar suas preferências de notificações',
            isButton: true,
          ),
          
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            // Mostrar indicador de carregamento
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saindo...'),
                duration: Duration(seconds: 1),
              ),
            );
            
            // Fazer logout usando o AuthViewModel
            await ref.read(authViewModelProvider.notifier).signOut();
            
            // Navegar para a tela de login após o logout
            if (mounted) {
              context.router.replaceNamed('/login');
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ).withAccessibility(
          label: 'Botão para sair da conta',
          hint: 'Toque para fazer logout da sua conta',
          isButton: true,
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required BuildContext context,
    required IconData iconData,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(iconData, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF29B6F6),
      ),
    ).withAccessibility(
      label: 'Link para $label',
      hint: 'Toque para $label',
      isButton: true,
    );
  }
} 
