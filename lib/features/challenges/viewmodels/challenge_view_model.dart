// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../models/challenge.dart';
import '../models/challenge_progress.dart';
import '../models/challenge_group.dart';
import '../repositories/challenge_repository.dart';
import 'package:ray_club_app/utils/text_sanitizer.dart';

/// Provider para o ChallengeViewModel
final challengeViewModelProvider = StateNotifierProvider<ChallengeViewModel, ChallengeState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return ChallengeViewModel(repository: repository, authRepository: authRepository);
});

/// Helper class para extrair dados do estado atual de forma mais segura
class ChallengeStateHelper {
  /// Retorna desafios do estado, ou uma lista vazia se não existirem
  static List<Challenge> getChallenges(ChallengeState state) {
    return state.challenges;
  }
  
  /// Retorna desafios filtrados do estado, ou uma lista vazia se não existirem
  static List<Challenge> getFilteredChallenges(ChallengeState state) {
    return state.filteredChallenges;
  }
  
  /// Retorna o desafio selecionado, ou null se não existir
  static Challenge? getSelectedChallenge(ChallengeState state) {
    return state.selectedChallenge;
  }
  
  /// Retorna convites pendentes do estado, ou uma lista vazia se não existirem
  static List<ChallengeGroupInvite> getPendingInvites(ChallengeState state) {
    return state.pendingInvites;
  }
  
  /// Retorna a lista de progresso do estado, ou uma lista vazia se não existir
  static List<ChallengeProgress> getProgressList(ChallengeState state) {
    return state.progressList;
  }
  
  /// Retorna o progresso do usuário no desafio selecionado, ou null se não existir
  static ChallengeProgress? getUserProgress(ChallengeState state) {
    return state.userProgress;
  }
  
  /// Obtém a mensagem de sucesso do estado
  static String? getSuccessMessage(ChallengeState state) {
    return state.successMessage;
  }
  
  /// Obtém a mensagem de erro do estado
  static String? getErrorMessage(ChallengeState state) {
    return state.errorMessage;
  }
  
  /// Verifica se o estado está carregando
  static bool isLoading(ChallengeState state) {
    return state.isLoading;
  }
  
  /// Retorna o desafio oficial, ou null se não existir
  static Challenge? getOfficialChallenge(ChallengeState state) {
    return state.officialChallenge;
  }
}

/// ViewModel para gerenciar desafios
class ChallengeViewModel extends StateNotifier<ChallengeState> {
  final ChallengeRepository _repository;
  final IAuthRepository _authRepository;

  ChallengeViewModel({
    required ChallengeRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository,
        super(ChallengeState.initial()) {
    // Inicializa carregando todos os desafios, incluindo o oficial
    loadAllChallengesWithOfficial();
  }

  /// Extrai mensagem de erro de uma exceção
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    
    // Mapeamento de erros comuns para mensagens amigáveis ao usuário
    if (error is DatabaseException) {
      return 'Erro ao acessar banco de dados. Por favor, tente novamente mais tarde.';
    }
    
    if (error is NetworkException) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }
    
    if (error is AppAuthException) {
      return 'Erro de autenticação. Faça login novamente.';
    }
    
    if (error is ValidationException) {
      return 'Dados inválidos. Verifique suas informações e tente novamente.';
    }
    
    // Para erros não mapeados, forneça uma mensagem genérica em vez de expor detalhes técnicos
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }

  /// Carrega todos os desafios, mas garante que o desafio oficial da Ray está incluído
  Future<void> loadAllChallengesWithOfficial() async {
    try {
      state = ChallengeState.loading();
      
      // Carrega todos os desafios
      final challenges = await _repository.getChallenges();
      
      // Verifica se há um desafio oficial
      final officialChallenge = await _repository.getOfficialChallenge();
      
      // Garante que o desafio oficial está na lista se existir
      final allChallenges = List<Challenge>.from(challenges);
      if (officialChallenge != null) {
        // Remove versões duplicadas do desafio oficial se existirem
        allChallenges.removeWhere((challenge) => challenge.id == officialChallenge.id);
        // Adiciona o desafio oficial
        allChallenges.add(officialChallenge);
      }
      
      // Carrega os convites pendentes para o usuário atual
      final currentUser = await _authRepository.getCurrentUser();
      final userId = currentUser?.id ?? '';
      
      if (userId.isEmpty) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      final pendingInvites = await _repository.getPendingInvites(userId);
      
      state = ChallengeState.success(
        challenges: allChallenges,
        filteredChallenges: allChallenges,
        pendingInvites: pendingInvites,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Carrega todos os desafios do repositório
  Future<void> loadChallenges() async {
    try {
      state = ChallengeState.loading();
      
      final challenges = await _repository.getChallenges();
      
      state = ChallengeState.success(
        challenges: challenges,
        filteredChallenges: challenges,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Carrega desafios criados por um usuário específico
  Future<void> loadUserChallenges(String userId) async {
    try {
      state = ChallengeState.loading();
      final challenges = await _repository.getUserChallenges(userId);
      state = ChallengeState.success(
        challenges: challenges,
        filteredChallenges: challenges,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Carrega desafios ativos (aqueles que ainda não terminaram)
  Future<void> loadActiveChallenges() async {
    try {
      state = ChallengeState.loading();
      final challenges = await _repository.getActiveChallenges();
      state = ChallengeState.success(
        challenges: challenges,
        filteredChallenges: challenges,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Carrega apenas o desafio oficial principal (Ray 21)
  Future<void> loadOfficialChallenge() async {
    state = state.copyWith(isLoading: true);
    try {
      // Busca o desafio oficial independente de datas ou status
      final challenge = await _repository.getOfficialChallenge();
      
      // Se encontrou um desafio oficial, carrega as informações completas
      if (challenge != null) {
        final officialWithRanking = await _loadChallengeWithRanking(challenge);
        state = state.copyWith(
          isLoading: false,
          officialChallenge: officialWithRanking,
          errorMessage: null,
        );
        debugPrint('✅ Desafio oficial carregado: ${officialWithRanking.title}');
      } else {
        // Não encontrou desafio oficial
        state = state.copyWith(
          isLoading: false,
          officialChallenge: null,
          errorMessage: 'Nenhum desafio oficial disponível no momento.',
        );
        debugPrint('⚠️ Nenhum desafio oficial encontrado');
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar desafio oficial: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar o desafio oficial: ${e.toString()}',
      );
    }
  }

  /// Carrega o desafio principal (em destaque)
  Future<void> loadMainChallenge() async {
    try {
      state = ChallengeState.loading();
      final challenge = await _repository.getMainChallenge();
      
      if (challenge != null) {
        state = ChallengeState.success(
          challenges: [challenge],
          filteredChallenges: [challenge],
          selectedChallenge: challenge,
        );
      } else {
        state = ChallengeState.error(
          message: 'Nenhum desafio em destaque encontrado',
        );
      }
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Verifica se o usuário atual é um administrador
  Future<bool> isAdmin() async {
    try {
      return await _repository.isCurrentUserAdmin();
    } catch (e) {
      return false;
    }
  }
  
  /// Alterna o status de administrador (apenas para testes)
  Future<void> toggleAdminStatus() async {
    try {
      await _repository.toggleAdminStatus();
    } catch (e) {
      state = ChallengeState(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Obtém detalhes de um desafio específico
  Future<void> getChallengeDetails(String challengeId) async {
    try {
      state = ChallengeState.loading();
      final challenge = await _repository.getChallengeById(challengeId);
      
      // Mantém a lista atual de desafios
      final currentChallenges = ChallengeStateHelper.getChallenges(state);
      
      // Obtém o ranking/progresso para este desafio
      final progressList = await _repository.getChallengeProgress(challengeId);
      
      state = ChallengeState.success(
        challenges: currentChallenges,
        filteredChallenges: currentChallenges,
        selectedChallenge: challenge,
        progressList: progressList,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Cria um novo desafio
  Future<void> createChallenge(Challenge challenge) async {
    try {
      state = ChallengeState.loading();
      final newChallenge = await _repository.createChallenge(challenge);
      
      // Mantém a lista atual de desafios e adiciona o novo
      final currentChallenges = ChallengeStateHelper.getChallenges(state);
      
      final updatedChallenges = [...currentChallenges, newChallenge];
      
      state = ChallengeState.success(
        challenges: updatedChallenges,
        filteredChallenges: updatedChallenges,
        selectedChallenge: newChallenge,
        message: 'Desafio criado com sucesso!',
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Atualiza um desafio existente
  Future<void> updateChallenge(Challenge challenge) async {
    try {
      state = ChallengeState.loading();
      await _repository.updateChallenge(challenge);
      
      // Mantém a lista atual de desafios e atualiza o modificado
      final currentChallenges = ChallengeStateHelper.getChallenges(state);
      final currentProgress = ChallengeStateHelper.getProgressList(state);
      
      final updatedChallenges = currentChallenges.map((c) {
        return c.id == challenge.id ? challenge : c;
      }).toList();
      
      state = ChallengeState.success(
        challenges: updatedChallenges,
        filteredChallenges: updatedChallenges,
        selectedChallenge: challenge,
        progressList: currentProgress,
        message: 'Desafio atualizado com sucesso!',
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Participa de um desafio
  Future<void> joinChallenge(String challengeId, String userId) async {
    try {
      state = ChallengeState.loading();
      
      await _repository.joinChallenge(challengeId, userId);
      
      // Recarrega os detalhes do desafio
      await getChallengeDetails(challengeId);
      
      // Atualiza a mensagem de sucesso
      state = ChallengeState.success(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        message: 'Você entrou no desafio',
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Sai de um desafio
  Future<void> leaveChallenge(String challengeId, String userId) async {
    try {
      state = ChallengeState.loading();
      
      await _repository.leaveChallenge(challengeId, userId);
      
      // Recarrega todos os desafios
      final challenges = await _repository.getChallenges();
      
      state = ChallengeState.success(
        challenges: challenges,
        filteredChallenges: challenges,
        message: 'Você saiu do desafio',
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Carrega os convites pendentes para um usuário
  Future<void> loadPendingInvites([String? userId]) async {
    try {
      state = ChallengeState.loading();
      
      // Se userId não for fornecido, obter do usuário atual
      String userIdToUse;
      if (userId != null) {
        userIdToUse = userId;
      } else {
        final currentUser = await _authRepository.getCurrentUser();
        if (currentUser == null) {
          throw AppAuthException(message: 'Usuário não autenticado');
        }
        userIdToUse = currentUser.id;
      }
      
      final invites = await _repository.getPendingInvites(userIdToUse);
      
      // Mantém a lista atual de desafios
      final currentChallenges = ChallengeStateHelper.getChallenges(state);
      
      state = ChallengeState.success(
        challenges: currentChallenges,
        filteredChallenges: currentChallenges,
        pendingInvites: invites,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Atualiza o progresso de um usuário em um desafio
  Future<void> updateUserProgress({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int points,
    required double completionPercentage,
  }) async {
    try {
      // Validação de IDs
      if (challengeId.trim().isEmpty) {
        throw ValidationException(message: 'ID do desafio não pode estar vazio');
      }
      
      if (userId.trim().isEmpty) {
        throw ValidationException(message: 'ID do usuário não pode estar vazio');
      }
      
      // Sanitização e validação do nome de usuário
      final sanitizedName = TextSanitizer.sanitizeText(userName);
      if (sanitizedName.isEmpty) {
        throw ValidationException(message: 'Nome do usuário não pode estar vazio');
      }
      
      // Sanitização do URL da foto (pode ser null)
      final sanitizedPhotoUrl = TextSanitizer.sanitizeUrl(userPhotoUrl);
      
      // Validação de valores numéricos
      if (points < 0) {
        throw ValidationException(message: 'Os pontos não podem ser negativos');
      }
      
      if (points > 1000000) {
        throw ValidationException(message: 'Valor de pontos excede o limite permitido');
      }
      
      if (completionPercentage < 0 || completionPercentage > 1) {
        throw ValidationException(message: 'O percentual de conclusão deve estar entre 0 e 100%');
      }
      
      state = ChallengeState.loading();
      await _repository.updateUserProgress(
        challengeId: challengeId,
        userId: userId,
        userName: sanitizedName,
        userPhotoUrl: sanitizedPhotoUrl,
        points: points,
        completionPercentage: completionPercentage,
      );
      
      // Obtém o ranking atualizado
      final progressList = await _repository.getChallengeProgress(challengeId);
      
      // Mantém o estado atual
      final challenges = ChallengeStateHelper.getChallenges(state);
      final filteredChallenges = ChallengeStateHelper.getFilteredChallenges(state);
      final selectedChallenge = ChallengeStateHelper.getSelectedChallenge(state);
      
      state = ChallengeState.success(
        challenges: challenges,
        filteredChallenges: filteredChallenges,
        selectedChallenge: selectedChallenge,
        progressList: progressList,
        message: 'Progresso atualizado com sucesso!',
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Carrega o ranking de um desafio
  Future<void> loadChallengeRanking(String challengeId) async {
    try {
      state = ChallengeState.loading();
      final progressList = await _repository.getChallengeProgress(challengeId);
      
      // Mantém o estado atual
      final challenges = ChallengeStateHelper.getChallenges(state);
      final filteredChallenges = ChallengeStateHelper.getFilteredChallenges(state);
      final selectedChallenge = ChallengeStateHelper.getSelectedChallenge(state);
      
      state = ChallengeState.success(
        challenges: challenges,
        filteredChallenges: filteredChallenges,
        selectedChallenge: selectedChallenge,
        progressList: progressList,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Limpa um erro
  void clearError() {
    state = ChallengeState.initial();
  }
  
  /// Exclui um desafio
  Future<bool> deleteChallenge(String id) async {
    try {
      state = ChallengeState.loading();
      await _repository.deleteChallenge(id);
      
      // Obtém a lista atual de desafios e remove o excluído
      final currentChallenges = ChallengeStateHelper.getChallenges(state);
      final updatedChallenges = currentChallenges.where((c) => c.id != id).toList();
      
      state = ChallengeState.success(
        challenges: updatedChallenges,
        filteredChallenges: updatedChallenges,
        message: 'Desafio excluído com sucesso!',
      );
      
      return true;
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
      return false;
    }
  }

  /// Cria um novo desafio e convida usuários
  Future<void> createChallengeWithInvites(Challenge challenge, List<String> invitedUserIds) async {
    try {
      state = ChallengeState.loading();
      
      // Cria o desafio
      final newChallenge = await _repository.createChallenge(challenge);
      
      // Não tentamos mais enviar convites para desafios, apenas para grupos
      
      // Recarrega os desafios
      final challenges = await _repository.getChallenges();
      
      state = ChallengeState.success(
        challenges: challenges,
        filteredChallenges: challenges,
        message: 'Desafio criado com sucesso',
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Convida um usuário para participar de um desafio
  Future<void> inviteUserToChallenge({
    required String challengeId,
    required String challengeTitle,
    required String inviterId,
    required String inviterName,
    required String inviteeId,
  }) async {
    try {
      // Atualizando estado para loading
      state = ChallengeState.loading();
      
      // Enviando o convite através do repositório
      await _repository.sendChallengeInvite(
        challengeId: challengeId,
        challengeTitle: challengeTitle,
        inviterId: inviterId,
        inviterName: inviterName,
        inviteeId: inviteeId,
      );
      
      // Busca o desafio atualizado para mostrar na UI
      final challenge = await _repository.getChallengeById(challengeId);
      
      // Atualiza o estado com sucesso
      state = ChallengeState.success(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: challenge,
        progressList: ChallengeStateHelper.getProgressList(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        message: 'Convite enviado com sucesso!',
      );
    } catch (e) {
      // Atualiza o estado com erro
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Acompanha um ranking atualizado de um desafio específico
  Future<void> watchChallengeRanking(String challengeId) async {
    try {
      // Primeiramente carrega os dados atuais para exibição imediata
      await getChallengeDetails(challengeId);
      
      // Inscreve-se em tempo real para atualizações da tabela challenge_participants
      final subscription = _repository.watchChallengeParticipants(challengeId).listen(
        (participantsList) {
          // Atualiza o estado com os novos dados de ranking
          final currentState = state;
          
          // Use o ChallengeStateHelper ou padrão de checking correto
          final challenges = ChallengeStateHelper.getChallenges(currentState);
          final filteredChallenges = ChallengeStateHelper.getFilteredChallenges(currentState);
          final selectedChallenge = ChallengeStateHelper.getSelectedChallenge(currentState);
          final pendingInvites = ChallengeStateHelper.getPendingInvites(currentState);
          
          // Atualiza o estado com os novos participantes
          state = ChallengeState.success(
            challenges: challenges,
            filteredChallenges: filteredChallenges,
            selectedChallenge: selectedChallenge,
            pendingInvites: pendingInvites,
            progressList: participantsList,
          );
        },
        onError: (error) {
          // Log do erro, mas não altera o estado para não interromper a UI
          print('Erro na stream de participantes: $error');
        },
      );
      
      // Registra a subscription para limpeza quando necessário
      _challengeSubscriptions[challengeId] = subscription;
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Cancela as subscrições de streams ao liberar o objeto
  @override
  void dispose() {
    _cancelAllSubscriptions();
    super.dispose();
  }
  
  // Armazena as subscrições ativas por ID de desafio
  final Map<String, StreamSubscription> _challengeSubscriptions = {};
  
  // Cancela uma subscrição específica
  void _cancelSubscription(String challengeId) {
    _challengeSubscriptions[challengeId]?.cancel();
    _challengeSubscriptions.remove(challengeId);
  }
  
  // Cancela todas as subscrições ativas
  void _cancelAllSubscriptions() {
    for (final subscription in _challengeSubscriptions.values) {
      subscription.cancel();
    }
    _challengeSubscriptions.clear();
  }
  
  /// Registra progresso em um desafio
  Future<void> registerProgress(String challengeId, String userId, int pointsToAdd) async {
    try {
      state = ChallengeState.loading();
      
      // Busca o usuário atual para obter o nome
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      final userName = currentUser.userMetadata?['name'] ?? 'Usuário';
      final userPhotoUrl = currentUser.userMetadata?['avatar_url'];
      
      // Obter o progresso atual do usuário
      final currentProgress = await _repository.getUserProgress(challengeId, userId);
      final currentPoints = currentProgress?.points ?? 0;
      final currentCompletion = currentProgress?.completionPercentage ?? 0.0;
      
      // Calcular novo progresso
      final newPoints = currentPoints + pointsToAdd;
      // Ajustar percentual de conclusão (exemplo: assumindo 1000 pontos = 100%)
      final challenge = await _repository.getChallengeById(challengeId);
      final totalPointsForCompletion = 1000; // Valor de exemplo, ajuste conforme necessário
      final newCompletionPercentage = (newPoints / totalPointsForCompletion).clamp(0.0, 1.0);
      
      await _repository.updateUserProgress(
        challengeId: challengeId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        points: newPoints,
        completionPercentage: newCompletionPercentage,
      );
      
      // Recarrega os detalhes do desafio
      await getChallengeDetails(challengeId);
      
      // Atualiza a mensagem de sucesso
      state = ChallengeState.success(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        message: 'Progresso registrado com sucesso',
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Registra um check-in manual em um desafio
  Future<void> registerChallengeCheckIn({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required DateTime date,
    required int points,
  }) async {
    try {
      // Validações rigorosas para garantir integridade dos dados
      if (challengeId.trim().isEmpty) {
        throw ValidationException(message: 'ID do desafio não pode estar vazio');
      }
      
      if (userId.trim().isEmpty) {
        throw ValidationException(message: 'ID do usuário não pode estar vazio');
      }
      
      if (points <= 0) {
        throw ValidationException(message: 'Pontos devem ser um valor positivo');
      }
      
      // Validar data (não pode ser no futuro)
      final now = DateTime.now();
      if (date.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59))) {
        throw ValidationException(message: 'Não é possível registrar check-ins futuros');
      }
      
      // Sanitização e validação do nome de usuário
      final sanitizedName = TextSanitizer.sanitizeText(userName);
      if (sanitizedName.isEmpty) {
        throw ValidationException(message: 'Nome do usuário não pode estar vazio');
      }
      
      // Sanitização do URL da foto (pode ser null)
      final sanitizedPhotoUrl = TextSanitizer.sanitizeUrl(userPhotoUrl);
      
      // Verifica se já existe check-in para a data
      final hasCheckIn = await _repository.hasCheckedInOnDate(userId, challengeId, date);
      if (hasCheckIn) {
        state = ChallengeState(
          challenges: ChallengeStateHelper.getChallenges(state),
          filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
          selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
          pendingInvites: ChallengeStateHelper.getPendingInvites(state),
          progressList: ChallengeStateHelper.getProgressList(state),
          successMessage: 'Você já registrou check-in para hoje neste desafio',
        );
        return;
      }
      
      state = ChallengeState.loading();
      
      // Registra o check-in
      try {
        await _repository.recordChallengeCheckIn(
          userId,
          challengeId,
          date,
          points,
          sanitizedName,
          userPhotoUrl != null ? TextSanitizer.sanitizeUrl(userPhotoUrl) : null,
        );
        
        // Verifica dias consecutivos para possíveis bônus
        final consecutiveDays = await _repository.getConsecutiveDaysCount(userId, challengeId);
        
        // Adiciona bônus por dias consecutivos - a cada 5 dias
        if (consecutiveDays > 0 && consecutiveDays % 5 == 0) {
          final bonusPoints = 5 * (consecutiveDays ~/ 5); // 5 pontos a cada 5 dias
          await _repository.addBonusPoints(
            userId,
            challengeId,
            bonusPoints,
            'Bônus por $consecutiveDays dias consecutivos',
            sanitizedName,
            userPhotoUrl != null ? TextSanitizer.sanitizeUrl(userPhotoUrl) : null,
          );
        }
        
        // Recarrega os detalhes do desafio para atualizar o estado
        await getChallengeDetails(challengeId);
        
        // Define mensagem de sucesso com informação sobre streak
        String successMessage = 'Check-in registrado com sucesso!';
        if (consecutiveDays > 1) {
          successMessage += ' Você está com uma sequência de $consecutiveDays dias consecutivos.';
        }
        
        state = ChallengeState.success(
          challenges: ChallengeStateHelper.getChallenges(state),
          filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
          selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
          pendingInvites: ChallengeStateHelper.getPendingInvites(state),
          progressList: ChallengeStateHelper.getProgressList(state),
          message: successMessage,
        );
      } catch (e) {
        state = ChallengeState.error(message: _getErrorMessage(e));
      }
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Registra um check-in automático de workout em desafios ativos
  Future<void> registerWorkoutCheckIn({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    DateTime? completedAt,
  }) async {
    try {
      // Validações de entrada
      if (userId.trim().isEmpty) {
        debugPrint('ID de usuário vazio, ignorando check-in de workout');
        return;
      }
      
      if (userName.trim().isEmpty) {
        debugPrint('Nome de usuário vazio, usando "Usuário" como padrão');
        userName = "Usuário";
      }
      
      // Usa a data atual se não for fornecida uma específica
      final checkInDate = completedAt ?? DateTime.now();
      
      // Validar data (não pode ser no futuro)
      final now = DateTime.now();
      if (checkInDate.isAfter(now)) {
        debugPrint('Data de check-in no futuro, ignorando');
        return;
      }
      
      // Carrega os desafios ativos do usuário
      final activeChallenges = await _repository.getUserActiveChallenges(userId);
      
      if (activeChallenges.isEmpty) {
        return; // Sem desafios ativos, nada a fazer
      }
      
      // Sanitiza o nome do usuário
      final sanitizedName = TextSanitizer.sanitizeText(userName);
      
      // Registra check-in para cada desafio ativo
      for (final challenge in activeChallenges) {
        // Verifica se já fez check-in hoje
        final hasCheckIn = await _repository.hasCheckedInOnDate(userId, challenge.id, checkInDate);
        if (!hasCheckIn) {
          // Registra o check-in
          await _repository.recordChallengeCheckIn(
            userId,
            challenge.id,
            checkInDate,
            challenge.points,
            sanitizedName,
            userPhotoUrl != null ? TextSanitizer.sanitizeUrl(userPhotoUrl) : null,
          );
          
          // Verifica dias consecutivos para bônus
          final consecutiveDays = await _repository.getConsecutiveDaysCount(userId, challenge.id);
          
          // Adiciona bônus por dias consecutivos - a cada 5 dias
          if (consecutiveDays > 0 && consecutiveDays % 5 == 0) {
            final bonusPoints = 5 * (consecutiveDays ~/ 5); // 5 pontos a cada 5 dias
            await _repository.addBonusPoints(
              userId,
              challenge.id,
              bonusPoints,
              'Bônus por $consecutiveDays dias consecutivos',
              sanitizedName,
              userPhotoUrl != null ? TextSanitizer.sanitizeUrl(userPhotoUrl) : null,
            );
          }
        }
      }
      
      // Não atualiza o estado UI aqui, pois isso é um processo em background
    } catch (e) {
      // Log do erro, mas não atualiza o estado UI
      debugPrint('Erro ao registrar check-in automático: ${e.toString()}');
      // O erro é silenciado para não interromper outros fluxos
    }
  }

  /// Carrega o progresso do usuário em um desafio específico
  Future<void> loadUserChallengeProgress({
    required String userId,
    required String challengeId,
  }) async {
    try {
      // Validações básicas
      if (challengeId.trim().isEmpty) {
        throw ValidationException(message: 'ID do desafio não pode estar vazio');
      }
      
      if (userId.trim().isEmpty) {
        throw ValidationException(message: 'ID do usuário não pode estar vazio');
      }
      
      // Define estado de carregamento
      state = ChallengeState.loading(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
      );
      
      // Busca o progresso do usuário
      final userProgress = await _repository.getUserProgress(challengeId, userId);
      
      // Se não houver progresso, atualiza estado sem progresso
      if (userProgress == null) {
        state = ChallengeState(
          challenges: ChallengeStateHelper.getChallenges(state),
          filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
          selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
          pendingInvites: ChallengeStateHelper.getPendingInvites(state),
          userProgress: null,
        );
        return;
      }
      
      // Verifica dias consecutivos para exibir streak atual
      final consecutiveDays = await _repository.getConsecutiveDaysCount(userId, challengeId);
      
      // Registra a informação de dias consecutivos no objeto de progresso
      final updatedProgress = userProgress.copyWith(
        consecutiveDays: consecutiveDays,
      );
      
      // Atualiza o estado com o progresso do usuário
      state = ChallengeState(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        userProgress: updatedProgress,
      );
    } catch (e) {
      state = ChallengeState.error(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        message: _getErrorMessage(e),
      );
    }
  }

  /// Carrega um desafio com seu ranking completo 
  Future<Challenge> _loadChallengeWithRanking(Challenge challenge) async {
    try {
      // Carrega o ranking para o desafio
      final progressList = await _repository.getChallengeProgress(challenge.id);
      
      // Como não podemos modificar o objeto challenge diretamente com o ranking,
      // retornamos o desafio original - o ranking é armazenado separadamente no estado
      if (progressList.isNotEmpty) {
        debugPrint('✅ Ranking carregado para desafio ${challenge.title}: ${progressList.length} participantes');
      }
      
      return challenge;
    } catch (e) {
      debugPrint('❌ Erro ao carregar ranking para desafio ${challenge.title}: $e');
      // Retorna o desafio original em caso de erro
      return challenge;
    }
  }

  /// Carrega as estatísticas do desafio para o usuário
  Future<void> loadChallengeStats({
    required String userId,
    required String challengeId,
  }) async {
    try {
      // Validações básicas
      if (challengeId.trim().isEmpty) {
        throw ValidationException(message: 'ID do desafio não pode estar vazio');
      }
      
      if (userId.trim().isEmpty) {
        throw ValidationException(message: 'ID do usuário não pode estar vazio');
      }
      
      // Define estado de carregamento
      state = ChallengeState.loading(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        userProgress: ChallengeStateHelper.getUserProgress(state),
      );
      
      // Busca o progresso do usuário
      final userProgress = await _repository.getUserProgress(challengeId, userId);
      
      // Verifica dias consecutivos atuais
      final consecutiveDays = await _repository.getConsecutiveDaysCount(userId, challengeId);
      
      // Verifica a última data de check-in e check-in de hoje
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final hasCheckedInToday = await _repository.hasCheckedInOnDate(userId, challengeId, normalizedToday);
      
      // Obtém o desafio atual para calcular informações
      final challenge = ChallengeStateHelper.getSelectedChallenge(state);
      
      // Prepara o estado atualizado
      final updatedState = ChallengeState(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: challenge,
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        userProgress: userProgress?.copyWith(
          consecutiveDays: consecutiveDays,
        ),
        successMessage: _formatChallengeStatsMessage(consecutiveDays, hasCheckedInToday),
      );
      
      state = updatedState;
    } catch (e) {
      state = ChallengeState.error(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        userProgress: ChallengeStateHelper.getUserProgress(state),
        message: _getErrorMessage(e),
      );
    }
  }
  
  /// Formata a mensagem de estatísticas do desafio baseado nos dias consecutivos
  String _formatChallengeStatsMessage(int consecutiveDays, bool hasCheckedInToday) {
    String message = '';
    
    if (consecutiveDays > 0) {
      message = 'Você está com $consecutiveDays ${consecutiveDays == 1 ? 'dia' : 'dias'} consecutivos!';
      
      // Adiciona informação sobre streak/bônus futuros
      if (consecutiveDays % 5 == 4 && !hasCheckedInToday) {
        message += ' Faça check-in hoje para ganhar bônus de sequência!';
      }
    }
    
    if (hasCheckedInToday) {
      if (message.isNotEmpty) {
        message += ' Você já fez check-in hoje!';
      } else {
        message = 'Você já fez check-in hoje!';
      }
    }
    
    return message;
  }

  // Funções Utilitárias
  @Deprecated('Use TextSanitizer.sanitizeText')
  String _sanitizeString(String str) {
    return TextSanitizer.sanitizeText(str);
  }
  
  @Deprecated('Use TextSanitizer.sanitizeNullableText')
  String? _sanitizeNullableString(String? str) {
    return TextSanitizer.sanitizeNullableText(str);
  }
}

/// Helper para inicialização de convites
void loadInvitesCallback(Function callback) {
  // Executa o callback diretamente no próximo frame  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
} 
