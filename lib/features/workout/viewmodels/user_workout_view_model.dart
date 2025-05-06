import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../repositories/workout_repository.dart';
import '../models/user_workout.dart';
import '../../../services/workout_challenge_service.dart';

/// Provider para o UserWorkoutViewModel
final userWorkoutViewModelProvider = StateNotifierProvider<UserWorkoutViewModel, UserWorkoutState>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final challengeService = ref.watch(workoutChallengeServiceProvider);
  return UserWorkoutViewModel(
    repository: repository, 
    authRepository: authRepository,
    challengeService: challengeService,
  );
});

/// ViewModel para gerenciar treinos do usuário
class UserWorkoutViewModel extends StateNotifier<UserWorkoutState> {
  final WorkoutRepository _repository;
  final IAuthRepository _authRepository;
  final WorkoutChallengeService _challengeService;

  UserWorkoutViewModel({
    required WorkoutRepository repository,
    required IAuthRepository authRepository,
    required WorkoutChallengeService challengeService,
  })  : _repository = repository,
        _authRepository = authRepository,
        _challengeService = challengeService,
        super(UserWorkoutState.initial());

  /// Inicia um treino para o usuário
  Future<void> startWorkout(String workoutId) async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      await _repository.startWorkout(workoutId, userId);
      
      state = UserWorkoutState.success(message: 'Treino iniciado com sucesso!');
    } catch (e) {
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// Conclui um treino para o usuário
  Future<void> completeWorkout(String workoutId) async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      await _repository.completeWorkout(workoutId, userId);
      
      // NOVO: Processar impacto nos desafios ativos
      await _processChallengeProgress(userId);
      
      state = UserWorkoutState.success(message: 'Treino concluído com sucesso!');
    } catch (e) {
      debugPrint('Erro ao completar treino: $e');
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// Atualiza o progresso de treino do usuário
  Future<void> updateWorkoutProgress(String workoutId, double progress) async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      await _repository.updateWorkoutProgress(workoutId, userId, progress);
      
      state = UserWorkoutState.success(message: 'Progresso atualizado!');
    } catch (e) {
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// Carrega o histórico de treinos do usuário
  Future<void> loadUserWorkoutHistory() async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      final workouts = await _repository.getUserWorkoutHistory(userId);
      
      state = UserWorkoutState.success(
        message: 'Histórico carregado com sucesso!',
        workouts: workouts,
      );
    } catch (e) {
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// NOVO: Processa o impacto do treino concluído nos desafios
  Future<void> _processChallengeProgress(String userId) async {
    try {
      final now = DateTime.now();
      await _challengeService.processWorkoutCompletion(userId, now);
    } catch (e) {
      // Apenas registrar o erro, mas não interromper o fluxo principal
      debugPrint('Erro ao processar progresso nos desafios: $e');
    }
  }

  /// Extrai mensagem de erro de uma exceção
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }
}

/// Estado para gerenciamento do UserWorkout
class UserWorkoutState {
  final List<UserWorkout> workouts;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const UserWorkoutState({
    this.workouts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Estado inicial
  factory UserWorkoutState.initial() => const UserWorkoutState();

  /// Estado de carregamento
  factory UserWorkoutState.loading() => const UserWorkoutState(isLoading: true);

  /// Estado de sucesso
  factory UserWorkoutState.success({
    List<UserWorkout> workouts = const [],
    String? message,
  }) => UserWorkoutState(
    workouts: workouts,
    successMessage: message,
  );

  /// Estado de erro
  factory UserWorkoutState.error({
    required String message,
  }) => UserWorkoutState(
    errorMessage: message,
  );
} 