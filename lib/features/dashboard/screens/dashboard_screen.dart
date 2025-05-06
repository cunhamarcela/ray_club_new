// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/features/dashboard/widgets/goals_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/progress_dashboard_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/water_intake_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/workout_calendar_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/challenge_progress_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/redeemed_benefits_widget.dart';
import 'package:ray_club_app/features/dashboard/widgets/workout_duration_widget.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';

/// Tela que exibe o dashboard completo do usuário
@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  /// Construtor
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    
    // Inicializa os dados quando a tela é carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }
  
  /// Inicializa todos os dados necessários para o dashboard
  Future<void> _initializeData() async {
    // Carrega os dados do dashboard
    ref.read(dashboardViewModelProvider.notifier).loadDashboardData();
    
    // Importante: Carrega o histórico de treinos para o calendário
    ref.read(workoutViewModelProvider.notifier).loadWorkoutHistory();
    
    debugPrint('✅ Dashboard: Dados inicializados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Botão de refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(dashboardViewModelProvider);
              // Recarrega também o histórico de treinos
              ref.read(workoutViewModelProvider.notifier).loadWorkoutHistory();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardViewModelProvider.notifier).refreshData();
          // Recarrega o histórico de treinos ao fazer pull-to-refresh
          await ref.read(workoutViewModelProvider.notifier).loadWorkoutHistory();
        },
        child: _buildDashboard(context, ref),
      ),
    );
  }
  
  /// Constrói o dashboard completo
  Widget _buildDashboard(BuildContext context, WidgetRef ref) {
    // Estado global do dashboard
    final dashboardState = ref.watch(dashboardDataProvider);
    
    return dashboardState.when(
      data: (_) => _buildDashboardContent(context),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Falha ao carregar o dashboard',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Recarrega o dashboard e o histórico de treinos
                  ref.refresh(dashboardViewModelProvider);
                  ref.read(workoutViewModelProvider.notifier).loadWorkoutHistory();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói o conteúdo do dashboard quando os dados estão disponíveis
  Widget _buildDashboardContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard de progresso
          const ProgressDashboardWidget(),
          
          const SizedBox(height: 16),
          
          // Desafio atual
          const ChallengeProgressWidget(),
          
          const SizedBox(height: 16),
          
          // Progresso de tempo de treino
          const WorkoutDurationWidget(),
          
          const SizedBox(height: 16),
          
          // Consumo de água
          const WaterIntakeWidget(),
          
          const SizedBox(height: 16),
          
          // Metas
          const GoalsWidget(),
          
          const SizedBox(height: 16),
          
          // Calendário de treinos
          const WorkoutCalendarWidget(),
          
          const SizedBox(height: 16),
          
          // Benefícios resgatados
          const RedeemedBenefitsWidget(),
          
          // Espaço extra no final para evitar que o último item fique sob a barra de navegação
          const SizedBox(height: 80),
        ],
      ),
    );
  }
} 