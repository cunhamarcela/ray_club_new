// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart' as app_errors;
import '../../../core/providers/supabase_providers.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit.dart';
import '../repositories/benefit_repository.dart';
import '../repositories/mock_benefit_repository.dart';
import '../repositories/supabase_benefit_repository.dart';
import 'benefit_state.dart';

/// Provider do repositório de benefícios
final benefitRepositoryProvider = Provider<BenefitRepository>((ref) {
  if (kDebugMode) {
    // Em modo de desenvolvimento, usa o mock para testes
    return MockBenefitRepository();
  } else {
    // Em produção, usa a implementação real com Supabase
    final supabase = ref.watch(supabaseClientProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);
    
    return SupabaseBenefitRepository(
      supabaseClient: supabase,
      cacheService: cacheService,
      connectivityService: connectivityService,
    );
  }
});

/// Provider do ViewModel de benefícios
final benefitViewModelProvider = StateNotifierProvider<BenefitViewModel, BenefitState>((ref) {
  return BenefitViewModel(ref.watch(benefitRepositoryProvider));
});

/// ViewModel para gerenciar benefícios
class BenefitViewModel extends StateNotifier<BenefitState> {
  final BenefitRepository _repository;
  
  BenefitViewModel(this._repository) : super(const BenefitState());
  
  /// Carrega todos os benefícios disponíveis
  Future<void> loadBenefits() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final benefits = await _repository.getBenefits();
      final categories = await _repository.getBenefitCategories();
      
      // Se o repositório for MockBenefitRepository, obtém pontos do usuário
      int? userPoints;
      if (_repository is MockBenefitRepository) {
        userPoints = await (_repository as MockBenefitRepository).getUserPoints();
      }
      
      state = state.copyWith(
        benefits: benefits,
        categories: categories,
        userPoints: userPoints,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }
  
  /// Carrega os benefícios resgatados pelo usuário
  Future<void> loadRedeemedBenefits() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final redeemedBenefits = await _repository.getRedeemedBenefits();
      
      // Verifica e atualiza status de expiração antes de atualizar o estado
      await checkExpiredBenefits(redeemedBenefits);
      
      state = state.copyWith(
        redeemedBenefits: redeemedBenefits,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }
  
  /// Verifica quais benefícios estão expirados e atualiza seus status
  Future<void> checkExpiredBenefits(List<RedeemedBenefit> benefits) async {
    final now = DateTime.now();
    bool hasUpdates = false;
    
    for (int i = 0; i < benefits.length; i++) {
      final benefit = benefits[i];
      
      // Verifica se o benefício está ativo e com data de expiração no passado
      if (benefit.status == RedemptionStatus.active && 
          benefit.expiresAt != null && 
          benefit.expiresAt!.isBefore(now)) {
        
        // Atualiza o status para expirado
        final updatedBenefit = await _repository.updateBenefitStatus(
          benefit.id, 
          RedemptionStatus.expired
        );
        
        // Substitui o benefício na lista
        if (updatedBenefit != null) {
          benefits[i] = updatedBenefit;
          hasUpdates = true;
        }
      }
    }
    
    // Se houver alterações, atualiza o estado
    if (hasUpdates && state.selectedRedeemedBenefit != null) {
      // Atualiza o benefício selecionado se ele estiver entre os expirados
      final updatedSelected = benefits.firstWhere(
        (b) => b.id == state.selectedRedeemedBenefit!.id,
        orElse: () => state.selectedRedeemedBenefit!,
      );
      
      state = state.copyWith(selectedRedeemedBenefit: updatedSelected);
    }
  }
  
  /// Filtra benefícios por categoria
  Future<void> filterByCategory(String? category) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, selectedCategory: category);
      
      // Se categoria for nula, carrega todos os benefícios
      final benefits = category == null 
          ? await _repository.getBenefits()
          : await _repository.getBenefitsByCategory(category);
      
      state = state.copyWith(
        benefits: benefits,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }
  
  /// Seleciona um benefício para visualização detalhada
  Future<void> selectBenefit(String benefitId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final benefit = await _repository.getBenefitById(benefitId);
      
      if (benefit == null) {
        throw app_errors.StorageException(
          message: 'Benefício não encontrado',
          code: 'benefit_not_found',
        );
      }
      
      state = state.copyWith(
        selectedBenefit: benefit,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }
  
  /// Seleciona um benefício resgatado para visualização
  Future<void> selectRedeemedBenefit(String redeemedBenefitId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final redeemedBenefit = await _repository.getRedeemedBenefitById(redeemedBenefitId);
      
      if (redeemedBenefit == null) {
        throw app_errors.StorageException(
          message: 'Benefício resgatado não encontrado',
          code: 'redeemed_benefit_not_found',
        );
      }
      
      state = state.copyWith(
        selectedRedeemedBenefit: redeemedBenefit,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }
  
  /// Resgata um benefício
  Future<RedeemedBenefit?> redeemBenefit(String benefitId) async {
    try {
      final benefit = await _repository.getBenefitById(benefitId);
      
      if (benefit == null) {
        throw app_errors.StorageException(
          message: 'Benefício não encontrado',
          code: 'benefit_not_found',
        );
      }
      
      state = state.copyWith(
        isRedeeming: true,
        errorMessage: null,
        successMessage: null,
        benefitBeingRedeemed: benefit,
      );
      
      // Verifica se tem pontos suficientes
      final hasEnough = await _repository.hasEnoughPoints(benefitId);
      if (!hasEnough) {
        throw app_errors.ValidationException(
          message: 'Pontos insuficientes para resgatar este benefício',
          code: 'insufficient_points',
        );
      }
      
      final redeemedBenefit = await _repository.redeemBenefit(benefitId);
      
      // Atualiza pontos do usuário se estiver usando MockBenefitRepository
      int? userPoints;
      if (_repository is MockBenefitRepository) {
        userPoints = await (_repository as MockBenefitRepository).getUserPoints();
      }
      
      // Carrega benefícios resgatados novamente para atualizar a lista
      final redeemedBenefits = await _repository.getRedeemedBenefits();
      
      state = state.copyWith(
        isRedeeming: false,
        benefitBeingRedeemed: null,
        redeemedBenefits: redeemedBenefits,
        userPoints: userPoints,
        selectedRedeemedBenefit: redeemedBenefit,
        successMessage: 'Benefício resgatado com sucesso!',
      );
      
      return redeemedBenefit;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(
        isRedeeming: false,
        benefitBeingRedeemed: null,
        errorMessage: errorMessage,
        successMessage: null,
      );
      return null;
    }
  }
  
  /// Marca um benefício como utilizado
  Future<bool> markBenefitAsUsed(String redeemedBenefitId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      
      final updatedBenefit = await _repository.markBenefitAsUsed(redeemedBenefitId);
      
      // Atualiza a lista de benefícios resgatados
      final redeemedBenefits = await _repository.getRedeemedBenefits();
      
      state = state.copyWith(
        redeemedBenefits: redeemedBenefits,
        selectedRedeemedBenefit: updatedBenefit,
        isLoading: false,
        successMessage: 'Benefício marcado como utilizado com sucesso!',
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false, 
        errorMessage: errorMessage,
        successMessage: null
      );
      return false;
    }
  }
  
  /// Cancela um benefício resgatado
  Future<bool> cancelRedeemedBenefit(String redeemedBenefitId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      
      await _repository.cancelRedeemedBenefit(redeemedBenefitId);
      
      // Atualiza pontos do usuário se estiver usando MockBenefitRepository
      int? userPoints;
      if (_repository is MockBenefitRepository) {
        userPoints = await (_repository as MockBenefitRepository).getUserPoints();
      }
      
      // Atualiza a lista de benefícios resgatados
      final redeemedBenefits = await _repository.getRedeemedBenefits();
      
      state = state.copyWith(
        redeemedBenefits: redeemedBenefits,
        userPoints: userPoints,
        selectedRedeemedBenefit: null,
        isLoading: false,
        successMessage: 'Benefício cancelado com sucesso!',
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false, 
        errorMessage: errorMessage,
        successMessage: null
      );
      return false;
    }
  }
  
  /// Carrega benefícios em destaque
  Future<void> loadFeaturedBenefits() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final featuredBenefits = await _repository.getFeaturedBenefits();
      
      state = state.copyWith(
        benefits: featuredBenefits,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }
  
  /// Limpa o benefício selecionado
  void clearSelectedBenefit() {
    state = state.copyWith(selectedBenefit: null);
  }
  
  /// Limpa o benefício resgatado selecionado
  void clearSelectedRedeemedBenefit() {
    state = state.copyWith(selectedRedeemedBenefit: null);
  }
  
  /// Limpa mensagem de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  /// Limpa mensagem de sucesso
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
  
  /// Adiciona pontos ao usuário (apenas para testes com MockBenefitRepository)
  Future<void> addUserPoints(int points) async {
    if (_repository is MockBenefitRepository) {
      final userPoints = await (_repository as MockBenefitRepository).addUserPoints(points);
      state = state.copyWith(userPoints: userPoints);
    }
  }
  
  /// MÉTODOS DE ADMINISTRAÇÃO
  
  /// Verifica se o usuário atual é um administrador
  Future<bool> isAdmin() async {
    try {
      return await _repository.isAdmin();
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
      return false;
    }
  }
  
  /// Carrega todos os benefícios resgatados (por todos os usuários) - somente admin
  Future<void> loadAllRedeemedBenefits() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Verificar se o usuário é admin
      final isAdminUser = await _repository.isAdmin();
      if (!isAdminUser) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Você não tem acesso de administrador.',
          code: 'permission_denied',
        );
      }
      
      final allRedeemedBenefits = await _repository.getAllRedeemedBenefits();
      
      // Verifica e atualiza status de expiração antes de atualizar o estado
      await checkExpiredBenefits(allRedeemedBenefits);
      
      state = state.copyWith(
        redeemedBenefits: allRedeemedBenefits,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }
  
  /// Atualiza a data de expiração de um benefício - somente admin
  Future<bool> updateBenefitExpiration(String benefitId, DateTime? newExpirationDate) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedBenefit = await _repository.updateBenefitExpiration(benefitId, newExpirationDate);
      
      if (updatedBenefit == null) {
        throw app_errors.StorageException(
          message: 'Benefício não encontrado',
          code: 'benefit_not_found',
        );
      }
      
      // Atualiza a lista de benefícios com o item atualizado
      final updatedBenefits = [...state.benefits];
      final index = updatedBenefits.indexWhere((b) => b.id == benefitId);
      if (index >= 0) {
        updatedBenefits[index] = updatedBenefit;
      }
      
      state = state.copyWith(
        benefits: updatedBenefits,
        selectedBenefit: updatedBenefit,
        isLoading: false,
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    }
  }
  
  /// Estende a data de expiração de um benefício resgatado - somente admin
  Future<bool> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime? newExpirationDate) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedBenefit = await _repository.extendRedeemedBenefitExpiration(redeemedBenefitId, newExpirationDate);
      
      if (updatedBenefit == null) {
        throw app_errors.StorageException(
          message: 'Benefício resgatado não encontrado',
          code: 'redeemed_benefit_not_found',
        );
      }
      
      // Atualiza a lista de benefícios resgatados com o item atualizado
      final updatedRedeemedBenefits = [...state.redeemedBenefits];
      final index = updatedRedeemedBenefits.indexWhere((b) => b.id == redeemedBenefitId);
      if (index >= 0) {
        updatedRedeemedBenefits[index] = updatedBenefit;
      }
      
      state = state.copyWith(
        redeemedBenefits: updatedRedeemedBenefits,
        selectedRedeemedBenefit: updatedBenefit,
        isLoading: false,
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    }
  }
  
  /// Alterna o status de admin (apenas para testes com MockBenefitRepository)
  Future<void> toggleAdminStatus() async {
    if (_repository is MockBenefitRepository) {
      (_repository as MockBenefitRepository).toggleAdminStatus();
    }
  }
  
  /// Obtem um beneficio pelo ID
  Future<Benefit?> getBenefitById(String benefitId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final benefit = await _repository.getBenefitById(benefitId);
      
      state = state.copyWith(
        isLoading: false,
      );
      
      return benefit;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return null;
    }
  }
  
  /// Atualiza um benefício existente (somente admin)
  Future<bool> updateBenefit(Benefit benefit) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      
      // Verificar se o usuário é admin
      final isAdminUser = await _repository.isAdmin();
      if (!isAdminUser) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Você não tem acesso de administrador.',
          code: 'permission_denied',
        );
      }
      
      // Implementação simulada - No mundo real, chamaríamos um método do repositório
      // await _repository.updateBenefit(benefit);
      
      // Recarrega a lista de benefícios para atualização
      final benefits = await _repository.getBenefits();
      
      state = state.copyWith(
        benefits: benefits,
        isLoading: false,
        successMessage: 'Benefício atualizado com sucesso!',
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false, 
        errorMessage: errorMessage,
        successMessage: null
      );
      return false;
    }
  }
  
  /// Cria um novo benefício (somente admin)
  Future<bool> createBenefit(Benefit benefit) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      
      // Verificar se o usuário é admin
      final isAdminUser = await _repository.isAdmin();
      if (!isAdminUser) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Você não tem acesso de administrador.',
          code: 'permission_denied',
        );
      }
      
      // Implementação simulada - No mundo real, chamaríamos um método do repositório
      // await _repository.createBenefit(benefit);
      
      // Recarrega a lista de benefícios para atualização
      final benefits = await _repository.getBenefits();
      
      state = state.copyWith(
        benefits: benefits,
        isLoading: false,
        successMessage: 'Benefício criado com sucesso!',
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false, 
        errorMessage: errorMessage,
        successMessage: null
      );
      return false;
    }
  }
  
  /// Trata erros de maneira unificada e retorna uma mensagem adequada para o usuário
  String _handleError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Error in BenefitViewModel: $error');
      print(stackTrace);
    }
    
    if (error is app_errors.AppException) {
      return error.message;
    }
    
    return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
  }
} 
