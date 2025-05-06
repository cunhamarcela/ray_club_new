// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_repository.dart';
import 'package:ray_club_app/features/goals/repositories/goal_repository.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/providers/challenge_providers.dart';

/// Provider para o DashboardViewModel
final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardData>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  final goalRepository = ref.watch(goalRepositoryProvider);
  final challengeRepository = ref.read(challengeRepositoryProvider);
  
  // Verifica se tem usuário autenticado
  final userId = authState.maybeWhen(
    authenticated: (user) => user.id,
    orElse: () => null,
  );
  
  return DashboardViewModel(
    repository,
    userId,
    goalRepository,
    challengeRepository,
  );
});

/// ViewModel para os dados do dashboard
class DashboardViewModel extends StateNotifier<AsyncValue<DashboardData>> {
  /// Repositório para acesso aos dados
  final DashboardRepository _repository;
  
  /// ID do usuário atual
  final String? _userId;
  
  /// Repositório para metas
  final GoalRepository _goalRepository;
  
  /// Repositório para desafios
  final ChallengeRepository _challengeRepository;
  
  /// Construtor que inicializa o estado como loading e carrega os dados
  DashboardViewModel(
    this._repository,
    this._userId,
    this._goalRepository,
    this._challengeRepository,
  ) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      debugPrint('📊 Dashboard inicializado para usuário: $_userId');
      loadDashboardData();
    } else {
      debugPrint('❌ Dashboard inicializado sem usuário autenticado');
      state = AsyncValue.error(
        'Usuário não autenticado',
        StackTrace.current,
      );
    }
  }
  
  /// Carrega os dados do dashboard do usuário
  Future<void> loadDashboardData() async {
    if (_userId == null) {
      debugPrint('❌ Tentativa de carregar dashboard sem usuário');
      state = AsyncValue.error(
        'Usuário não autenticado',
        StackTrace.current,
      );
      return;
    }
    
    // Marca como carregando
    state = const AsyncValue.loading();
    
    try {
      debugPrint('🔄 Carregando dados do dashboard para usuário: $_userId');
      // Carrega os dados básicos do dashboard
      var dashboardData = await _repository.getDashboardData(_userId!);
      
      debugPrint('✅ Dados carregados com sucesso:');
      debugPrint('✅ - Progresso: ${dashboardData.userProgress.totalWorkouts} treinos, ${dashboardData.userProgress.currentStreak} dias de streak');
      
      // Verificar os dados de água
      if (dashboardData.additionalData['water_intake'] == null) {
        debugPrint('🚰 Dados de água não encontrados, iniciando criação...');
        // Criar registro de água se não existir
        await initializeWaterIntakeIfNeeded();
      } else {
        final waterIntakeData = dashboardData.additionalData['water_intake'] as Map<String, dynamic>;
        final id = waterIntakeData['id'];
        
        if (id == null || id.toString().trim().isEmpty) {
          debugPrint('🚰 Dados de água encontrados mas com ID vazio, atualizando...');
          await initializeWaterIntakeIfNeeded();
        } else {
          debugPrint('🚰 Dados de água encontrados com ID: $id');
        }
      }
      
      // Obter metas atualizadas diretamente do repositório de metas
      try {
        debugPrint('🎯 Buscando metas atualizadas do repositório...');
        final userGoals = await _goalRepository.getUserGoals();
        
        // Converter para o formato esperado pelo dashboard
        final goalsData = userGoals.map((goal) => {
          'id': goal.id,
          'title': goal.title,
          'current_value': goal.progress,
          'target_value': goal.target,
          'unit': goal.unit,
          'is_completed': goal.isCompleted,
          'is_integer': goal.type == GoalType.workout || goal.type == GoalType.steps,
          'type': goal.type.toString().split('.').last,
          'created_at': goal.createdAt.toIso8601String(),
          'updated_at': goal.updatedAt?.toIso8601String(),
        }).toList();
        
        // Atualizar os dados adicionais com as metas atualizadas
        final updatedAdditionalData = Map<String, dynamic>.from(dashboardData.additionalData);
        updatedAdditionalData['goals'] = goalsData;
        
        // Atualizar o dashboardData com as novas metas
        dashboardData = dashboardData.copyWith(
          additionalData: updatedAdditionalData,
        );
        
        debugPrint('🎯 Metas encontradas: ${goalsData.length}');
      } catch (e) {
        debugPrint('⚠️ Erro ao buscar metas do repositório: $e');
        // Usaremos as metas que vieram no dashboard original
      }
      
      // Obter dados mais detalhados do desafio atual
      if (dashboardData.currentChallenge != null) {
        try {
          debugPrint('🏆 Buscando dados detalhados do desafio atual: ${dashboardData.currentChallenge!.id}');
          
          // Obter progresso atualizado do desafio
          final updatedProgress = await _challengeRepository.getUserProgress(
            challengeId: dashboardData.currentChallenge!.id,
            userId: _userId!,
          );
          
          // Obter ranking do desafio
          final challengeRanking = await _challengeRepository.getChallengeProgress(
            dashboardData.currentChallenge!.id,
          );
          
          debugPrint('📈 Ranking carregado: ${challengeRanking.length} participantes');
          
          // Atualizar dados do desafio com copyWith
          if (updatedProgress != null) {
            dashboardData = dashboardData.copyWith(
              challengeProgress: updatedProgress,
            );
            debugPrint('📊 Progresso atualizado: ${updatedProgress.points} pontos, posição ${updatedProgress.position}');
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao carregar detalhes do desafio: $e');
          // Manteremos os dados originais do desafio
        }
      } else {
        debugPrint('ℹ️ Nenhum desafio ativo encontrado');
        
        // Tentar encontrar um desafio que o usuário esteja participando
        try {
          final userChallenges = await _challengeRepository.getUserActiveChallenges(_userId!);
          if (userChallenges.isNotEmpty) {
            try {
              // Obter progresso para este desafio
              final progress = await _challengeRepository.getUserProgress(
                challengeId: userChallenges.first.id,
                userId: _userId!,
              );
              
              // Atualizar dados usando copyWith
              dashboardData = dashboardData.copyWith(
                currentChallenge: userChallenges.first,
                challengeProgress: progress,
              );
              
              debugPrint('🏆 Encontrado desafio ativo: ${userChallenges.first.title}');
              if (progress != null) {
                debugPrint('📊 Progresso: ${progress.points} pontos, posição ${progress.position}');
              }
            } catch (e) {
              debugPrint('Erro ao processar desafio atual: $e');
              // Manter apenas o desafio sem o progresso se houver erro
              dashboardData = dashboardData.copyWith(
                currentChallenge: userChallenges.first,
              );
            }
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao buscar desafios ativos: $e');
        }
      }
      
      // Atualiza o estado com os dados carregados e enriquecidos
      state = AsyncValue.data(dashboardData);
    } catch (error, stackTrace) {
      // Em caso de erro, atualiza o estado com o erro
      debugPrint('❌ Erro ao carregar dashboard: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Força o recarregamento dos dados
  Future<void> refreshData() async {
    debugPrint('🔄 Atualizando dados do dashboard');
    await loadDashboardData();
  }
  
  /// Adiciona um copo de água
  Future<void> addWaterGlass() async {
    // Verifica se há dados carregados
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de adicionar água sem dados/usuário');
      return;
    }
    
    final waterIntakeData = currentData.additionalData['water_intake'];
    if (waterIntakeData == null) {
      debugPrint('⚠️ Dados de água não encontrados, inicializando...');
      await initializeWaterIntakeIfNeeded();
      return;
    }
    
    // CORRIGIDO: Verificar se o ID existe e não é nulo ou vazio antes de usar
    final id = waterIntakeData['id'];
    if (id == null || id.toString().trim().isEmpty) {
      debugPrint('⚠️ Water intake ID é nulo ou vazio, tentando reinicializar...');
      await initializeWaterIntakeIfNeeded();
      return;
    }
    
    final String waterIntakeId = id.toString();
    final int currentCups = (waterIntakeData['cups'] ?? 0) as int;
    final int newGlassCount = currentCups + 1;
    
    debugPrint('🚰 Adicionando copo de água: $currentCups -> $newGlassCount');
    
    // Atualiza localmente para feedback imediato
    final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
    updatedAdditionalData['water_intake'] = {
      ...waterIntakeData as Map<String, dynamic>,
      'cups': newGlassCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    // Otimisticamente atualiza a UI enquanto a operação acontece no bg
    state = AsyncValue.data(
      currentData.copyWith(
        additionalData: updatedAdditionalData,
      ),
    );
    
    try {
      // Atualiza no backend
      await _repository.updateWaterIntake(
        _userId!,
        waterIntakeId,
        newGlassCount,
      );
      debugPrint('✅ Água atualizada no backend com sucesso');
    } catch (error) {
      // Em caso de erro, reverte a alteração otimista
      debugPrint('❌ Erro ao atualizar água: $error');
      state = AsyncValue.data(currentData);
      
      // Recarrega os dados
      await loadDashboardData();
    }
  }
  
  /// Remove um copo de água
  Future<void> removeWaterGlass() async {
    // Verifica se há dados carregados
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de remover água sem dados/usuário');
      return;
    }
    
    final waterIntakeData = currentData.additionalData['water_intake'];
    if (waterIntakeData == null) {
      debugPrint('⚠️ Dados de água não encontrados ao tentar remover');
      return;
    }
    
    // CORRIGIDO: Verificar se o ID existe e não é nulo ou vazio antes de usar
    final id = waterIntakeData['id'];
    if (id == null || id.toString().trim().isEmpty) {
      debugPrint('⚠️ Water intake ID é nulo ou vazio, tentando reinicializar...');
      await initializeWaterIntakeIfNeeded();
      return;
    }
    
    final String waterIntakeId = id.toString();
    final int currentCups = (waterIntakeData['cups'] ?? 0) as int;
    if (currentCups <= 0) {
      debugPrint('ℹ️ Já está em 0 copos, nada a remover');
      return;
    }
    
    final int newGlassCount = currentCups - 1;
    debugPrint('🚰 Removendo copo de água: $currentCups -> $newGlassCount');
    
    // Atualiza localmente para feedback imediato
    final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
    updatedAdditionalData['water_intake'] = {
      ...waterIntakeData as Map<String, dynamic>,
      'cups': newGlassCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    // Otimisticamente atualiza a UI enquanto a operação acontece no bg
    state = AsyncValue.data(
      currentData.copyWith(
        additionalData: updatedAdditionalData,
      ),
    );
    
    try {
      // Atualiza no backend
      await _repository.updateWaterIntake(
        _userId!,
        waterIntakeId,
        newGlassCount,
      );
      debugPrint('✅ Água (remoção) atualizada no backend com sucesso');
    } catch (error) {
      // Em caso de erro, reverte a alteração otimista
      debugPrint('❌ Erro ao atualizar água (remoção): $error');
      state = AsyncValue.data(currentData);
      
      // Recarrega os dados
      await loadDashboardData();
    }
  }
  
  /// Inicializa o registro de água para hoje se não existir
  Future<void> initializeWaterIntakeIfNeeded() async {
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de inicializar água sem dados/usuário');
      return;
    }
    
    final waterIntakeData = currentData.additionalData['water_intake'];
    final hasEmptyId = waterIntakeData != null && 
                      (waterIntakeData['id'] == null || 
                       waterIntakeData['id'].toString().trim().isEmpty);
    
    // Se o water intake não existe ou tem ID vazio, precisamos buscar ou criar
    if (waterIntakeData == null || hasEmptyId) {
      debugPrint('🔄 Inicializando registro de água para hoje');
      
      try {
        // Primeiro, tenta buscar um registro existente para hoje
        final today = DateTime.now();
        final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        
        final result = await _repository.createWaterIntakeForToday(_userId!);
        
        if (result != null) {
          debugPrint('✅ Registro de água obtido/criado com ID: $result');
          
          // Importante: Atualizar o estado imediatamente com o ID correto para evitar loop
          if (waterIntakeData != null) {
            // Atualizar o ID no objeto existente
            final updatedWaterIntake = Map<String, dynamic>.from(waterIntakeData as Map<String, dynamic>);
            updatedWaterIntake['id'] = result;
            
            final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
            updatedAdditionalData['water_intake'] = updatedWaterIntake;
            
            // Atualizar o estado com o ID corrigido
            state = AsyncValue.data(
              currentData.copyWith(
                additionalData: updatedAdditionalData,
              ),
            );
            debugPrint('✅ Atualizado ID do registro de água no estado local');
          } else {
            // Recarrega os dados completos
            await loadDashboardData();
          }
        } else {
          debugPrint('⚠️ Não foi possível obter/criar registro de água');
          // Recarrega os dados para diagnóstico
          await loadDashboardData();
        }
      } catch (error) {
        // Log de erro, mas não quebramos a UI
        debugPrint('❌ Erro ao inicializar registro de água: $error');
        // Forçar recarregamento dos dados após erro
        await loadDashboardData();
      }
    } else {
      final id = waterIntakeData['id'];
      debugPrint('ℹ️ Registro de água já existe com ID: $id, nada a fazer');
    }
  }
  
  /// Incrementa um valor de meta
  Future<void> incrementGoalValue(int goalIndex) async {
    debugPrint('🎯 Tentando incrementar meta $goalIndex');
    
    // Verifica se há dados carregados
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de incrementar meta sem dados/usuário');
      return;
    }
    
    final goals = currentData.additionalData['goals'] as List<dynamic>?;
    if (goals == null || goals.isEmpty || goalIndex >= goals.length) {
      debugPrint('❌ Índice de meta inválido ou lista de metas vazia');
      return;
    }
    
    // Obter a meta específica
    final goal = goals[goalIndex] as Map<String, dynamic>;
    
    // Obter valores atuais
    final double currentValue = (goal['current_value'] as num?)?.toDouble() ?? 0.0;
    final double targetValue = (goal['target_value'] as num?)?.toDouble() ?? 100.0;
    final String id = goal['id'] as String? ?? '';
    
    if (id.isEmpty) {
      debugPrint('❌ Meta sem ID, não é possível atualizar');
      return;
    }
    
    // Verificar se a meta já foi concluída
    if (currentValue >= targetValue) {
      debugPrint('ℹ️ Meta já concluída, não é possível incrementar mais');
      return;
    }
    
    // Calcular novo valor (incrementar de 1 em 1 ou 0.5 em 0.5)
    final bool isInteger = goal['is_integer'] as bool? ?? false;
    final double increment = isInteger ? 1.0 : 0.5;
    final double newValue = (currentValue + increment).clamp(0.0, targetValue);
    
    debugPrint('🎯 Incrementando meta $goalIndex: $currentValue -> $newValue');
    
    // Atualizar localmente para feedback imediato
    final updatedGoals = List<dynamic>.from(goals);
    final updatedGoal = Map<String, dynamic>.from(goal);
    updatedGoal['current_value'] = newValue;
    updatedGoal['is_completed'] = newValue >= targetValue;
    updatedGoals[goalIndex] = updatedGoal;
    
    final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
    updatedAdditionalData['goals'] = updatedGoals;
    
    // Atualizar estado
    state = AsyncValue.data(
      currentData.copyWith(
        additionalData: updatedAdditionalData,
      ),
    );
    
    // Atualizar a meta no repositório
    try {
      await _goalRepository.updateGoalProgress(id, newValue);
      debugPrint('✅ Meta atualizada no backend com sucesso');
    } catch (error) {
      debugPrint('❌ Erro ao atualizar meta: $error');
      // Em caso de erro, voltar ao estado anterior
      state = AsyncValue.data(currentData);
    }
  }
  
  /// Decrementa um valor de meta
  Future<void> decrementGoalValue(int goalIndex) async {
    debugPrint('🎯 Tentando decrementar meta $goalIndex');
    
    // Verifica se há dados carregados
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de decrementar meta sem dados/usuário');
      return;
    }
    
    final goals = currentData.additionalData['goals'] as List<dynamic>?;
    if (goals == null || goals.isEmpty || goalIndex >= goals.length) {
      debugPrint('❌ Índice de meta inválido ou lista de metas vazia');
      return;
    }
    
    // Obter a meta específica
    final goal = goals[goalIndex] as Map<String, dynamic>;
    
    // Obter valores atuais
    final double currentValue = (goal['current_value'] as num?)?.toDouble() ?? 0.0;
    final double targetValue = (goal['target_value'] as num?)?.toDouble() ?? 100.0;
    final String id = goal['id'] as String? ?? '';
    
    if (id.isEmpty) {
      debugPrint('❌ Meta sem ID, não é possível atualizar');
      return;
    }
    
    // Verificar se a meta já está em zero
    if (currentValue <= 0) {
      debugPrint('ℹ️ Meta já em zero, não é possível decrementar mais');
      return;
    }
    
    // Calcular novo valor (decrementar de 1 em 1 ou 0.5 em 0.5)
    final bool isInteger = goal['is_integer'] as bool? ?? false;
    final double decrement = isInteger ? 1.0 : 0.5;
    final double newValue = (currentValue - decrement).clamp(0.0, targetValue);
    
    debugPrint('🎯 Decrementando meta $goalIndex: $currentValue -> $newValue');
    
    // Atualizar localmente para feedback imediato
    final updatedGoals = List<dynamic>.from(goals);
    final updatedGoal = Map<String, dynamic>.from(goal);
    updatedGoal['current_value'] = newValue;
    updatedGoal['is_completed'] = newValue >= targetValue;
    updatedGoals[goalIndex] = updatedGoal;
    
    final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
    updatedAdditionalData['goals'] = updatedGoals;
    
    // Atualizar estado
    state = AsyncValue.data(
      currentData.copyWith(
        additionalData: updatedAdditionalData,
      ),
    );
    
    // Atualizar a meta no repositório
    try {
      await _goalRepository.updateGoalProgress(id, newValue);
      debugPrint('✅ Meta atualizada no backend com sucesso');
    } catch (error) {
      debugPrint('❌ Erro ao atualizar meta: $error');
      // Em caso de erro, voltar ao estado anterior
      state = AsyncValue.data(currentData);
    }
  }
} 