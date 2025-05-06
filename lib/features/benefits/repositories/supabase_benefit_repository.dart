// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import '../models/benefit.dart';
import '../models/redeemed_benefit.dart';
import 'benefit_repository.dart';
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/core/services/connectivity_service.dart';
import 'package:ray_club_app/utils/log_utils.dart';

/// Implementação do BenefitRepository usando Supabase
class SupabaseBenefitRepository implements BenefitRepository {
  final supabase.SupabaseClient _supabaseClient;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;
  
  // Constantes para chaves de cache
  static const String _benefitsCacheKey = 'benefits_cache';
  static const String _categoriesCacheKey = 'benefit_categories_cache';
  static const String _redeemedBenefitsCacheKey = 'redeemed_benefits_cache';
  static const String _featuredBenefitsCacheKey = 'featured_benefits_cache';
  
  // Constantes para nomes de tabelas
  static const String _benefitsTable = 'benefits';
  static const String _redeemedBenefitsTable = 'redeemed_benefits';
  static const String _usersTable = 'users';
  
  SupabaseBenefitRepository({
    required supabase.SupabaseClient supabaseClient,
    required CacheService cacheService,
    required ConnectivityService connectivityService,
  }) : _supabaseClient = supabaseClient,
      _cacheService = cacheService,
      _connectivityService = connectivityService;
  
  @override
  Future<List<Benefit>> getBenefits() async {
    try {
      // Verificar conectividade
      final hasConnection = _connectivityService.hasConnection;
      
      // Se não há conexão, tentar obter do cache
      if (!hasConnection) {
        final cachedBenefits = await _cacheService.getObjectList<Benefit>(
          _benefitsCacheKey,
          fromJson: Benefit.fromJson,
        );
        
        if (cachedBenefits != null) {
          return cachedBenefits;
        }
        
        // Se não há cache, lançar exceção
        throw app_errors.NetworkException(
          message: 'Sem conexão com a internet. Não foi possível carregar benefícios.',
          code: 'no_connection',
        );
      }
      
      // Com conexão, obter dados do servidor
      final response = await _supabaseClient
          .from(_benefitsTable)
          .select()
          .order('created_at', ascending: false);
      
      final benefits = response.map((json) => Benefit.fromJson(json)).toList();
      
      // Salvar em cache para uso offline
      await _cacheService.setObjectList<Benefit>(
        _benefitsCacheKey,
        benefits,
        fromJson: Benefit.fromJson,
        toJson: (benefit) => benefit.toJson(),
        expiryDuration: const Duration(days: 2),
      );
      
      return benefits;
    } catch (e) {
      // Se for erro de rede e temos cache, tentar recuperar do cache mesmo
      if (e is app_errors.NetworkException) {
        final cachedBenefits = await _cacheService.getObjectList<Benefit>(
          _benefitsCacheKey,
          fromJson: Benefit.fromJson,
          ignoreExpiry: true, // Ignorar expiração em caso de erro de rede
        );
        
        if (cachedBenefits != null) {
          return cachedBenefits;
        }
      }
      
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Falha ao buscar benefícios',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<Benefit>> getBenefitsByCategory(String category) async {
    try {
      // Verificar conectividade
      final hasConnection = _connectivityService.hasConnection;
      
      // Chave de cache específica para categoria
      final categoryCacheKey = '${_benefitsCacheKey}_category_$category';
      
      // Se não há conexão, tentar obter do cache
      if (!hasConnection) {
        final cachedBenefits = await _cacheService.getObjectList<Benefit>(
          categoryCacheKey,
          fromJson: Benefit.fromJson,
        );
        
        if (cachedBenefits != null) {
          return cachedBenefits;
        }
        
        // Tentar filtrar do cache geral
        final allCachedBenefits = await _cacheService.getObjectList<Benefit>(
          _benefitsCacheKey,
          fromJson: Benefit.fromJson,
        );
        
        if (allCachedBenefits != null) {
          final filteredBenefits = allCachedBenefits
              .where((benefit) => benefit.category == category)
              .toList();
          
          // Salvar esta categoria em cache para uso futuro
          await _cacheService.setObjectList<Benefit>(
            categoryCacheKey,
            filteredBenefits,
            fromJson: Benefit.fromJson,
            toJson: (benefit) => benefit.toJson(),
          );
          
          return filteredBenefits;
        }
        
        // Se não há cache, lançar exceção
        throw app_errors.NetworkException(
          message: 'Sem conexão com a internet. Não foi possível carregar benefícios.',
          code: 'no_connection',
        );
      }
      
      // Com conexão, obter dados do servidor
      final response = await _supabaseClient
          .from(_benefitsTable)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      final benefits = response.map((json) => Benefit.fromJson(json)).toList();
      
      // Salvar em cache para uso offline
      await _cacheService.setObjectList<Benefit>(
        categoryCacheKey,
        benefits,
        fromJson: Benefit.fromJson,
        toJson: (benefit) => benefit.toJson(),
      );
      
      return benefits;
    } catch (e) {
      // Tratamento de erros similar ao método getBenefits()
      if (e is app_errors.NetworkException) {
        // Tentar recuperar do cache específico da categoria
        final categoryCacheKey = '${_benefitsCacheKey}_category_$category';
        final cachedBenefits = await _cacheService.getObjectList<Benefit>(
          categoryCacheKey,
          fromJson: Benefit.fromJson,
          ignoreExpiry: true,
        );
        
        if (cachedBenefits != null) {
          return cachedBenefits;
        }
        
        // Ou do cache geral, se disponível
        final allCachedBenefits = await _cacheService.getObjectList<Benefit>(
          _benefitsCacheKey,
          fromJson: Benefit.fromJson,
          ignoreExpiry: true,
        );
        
        if (allCachedBenefits != null) {
          return allCachedBenefits
              .where((benefit) => benefit.category == category)
              .toList();
        }
      }
      
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao buscar benefícios por categoria',
        originalError: e,
      );
    }
  }
  
  @override
  Future<Benefit?> getBenefitById(String id) async {
    try {
      final response = await _supabaseClient
          .from(_benefitsTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Benefit.fromJson(response);
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao buscar detalhes do benefício',
        originalError: e,
      );
    }
  }
  
  @override
  Future<RedeemedBenefit> redeemBenefit(String benefitId) async {
    try {
      // Verificar usuário autenticado
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'unauthenticated',
        );
      }
      
      // Buscar benefício
      final benefit = await getBenefitById(benefitId);
      if (benefit == null) {
        throw app_errors.StorageException(
          message: 'Benefício não encontrado',
          code: 'benefit_not_found',
        );
      }
      
      // Verificar se o benefício está expirado
      if (benefit.expiresAt != null && benefit.expiresAt!.isBefore(DateTime.now())) {
        throw app_errors.ValidationException(
          message: 'Este benefício expirou',
          code: 'benefit_expired',
        );
      }
      
      // Verificar se usuário tem pontos suficientes
      final hasEnough = await hasEnoughPoints(benefitId);
      if (!hasEnough) {
        throw app_errors.ValidationException(
          message: 'Pontos insuficientes para resgatar este benefício',
          code: 'insufficient_points',
        );
      }
      
      // Define data de expiração padrão (30 dias)
      final expiresAt = DateTime.now().add(const Duration(days: 30));
      
      // Gerar código de resgate aleatório
      final redemptionCode = _generateRedemptionCode();
      
      // Criar registro de benefício resgatado
      final response = await _supabaseClient
          .from(_redeemedBenefitsTable)
          .insert({
            'benefit_id': benefitId,
            'user_id': userId,
            'redeemed_at': DateTime.now().toIso8601String(),
            'status': 'active',
            'redemption_code': redemptionCode,
            'expires_at': expiresAt.toIso8601String(),
            'benefit_snapshot': benefit.toJson(),
          })
          .select()
          .single();
      
      return RedeemedBenefit.fromJson(response);
    } catch (e) {
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao resgatar benefício',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<RedeemedBenefit>> getRedeemedBenefits() async {
    try {
      // Verificar usuário autenticado
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'unauthenticated',
        );
      }
      
      // Verificar conectividade
      final hasConnection = _connectivityService.hasConnection;
      
      // Se não há conexão, tentar obter do cache
      if (!hasConnection) {
        final cachedBenefits = await _cacheService.getObjectList<RedeemedBenefit>(
          _redeemedBenefitsCacheKey,
          fromJson: RedeemedBenefit.fromJson,
        );
        
        if (cachedBenefits != null) {
          return cachedBenefits;
        }
        
        throw app_errors.NetworkException(
          message: 'Sem conexão com a internet. Não foi possível carregar benefícios resgatados.',
          code: 'no_connection',
        );
      }
      
      final response = await _supabaseClient
          .from(_redeemedBenefitsTable)
          .select()
          .eq('user_id', userId)
          .order('redeemed_at', ascending: false);
      
      final redeemedBenefits = response.map((json) => RedeemedBenefit.fromJson(json)).toList();
      
      // Salvar em cache para uso offline
      await _cacheService.setObjectList<RedeemedBenefit>(
        _redeemedBenefitsCacheKey,
        redeemedBenefits,
        fromJson: RedeemedBenefit.fromJson,
        toJson: (benefit) => benefit.toJson(),
      );
      
      return redeemedBenefits;
    } catch (e) {
      // Tratamento de erros similar aos outros métodos
      if (e is app_errors.NetworkException) {
        final cachedBenefits = await _cacheService.getObjectList<RedeemedBenefit>(
          _redeemedBenefitsCacheKey,
          fromJson: RedeemedBenefit.fromJson,
          ignoreExpiry: true,
        );
        
        if (cachedBenefits != null) {
          return cachedBenefits;
        }
      }
      
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao buscar benefícios resgatados',
        originalError: e,
      );
    }
  }
  
  @override
  Future<RedeemedBenefit?> getRedeemedBenefitById(String id) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'unauthenticated',
        );
      }
      
      final response = await _supabaseClient
          .from(_redeemedBenefitsTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return RedeemedBenefit.fromJson(response);
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao buscar detalhes do benefício resgatado',
        originalError: e,
      );
    }
  }
  
  @override
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'unauthenticated',
        );
      }
      
      final now = DateTime.now();
      
      final response = await _supabaseClient
          .from(_redeemedBenefitsTable)
          .update({
            'status': 'used',
            'used_at': now.toIso8601String(),
          })
          .eq('id', redeemedBenefitId)
          .eq('user_id', userId) // Garantir que o benefício pertence ao usuário
          .select()
          .single();
      
      return RedeemedBenefit.fromJson(response);
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao marcar benefício como utilizado',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> cancelRedeemedBenefit(String redeemedBenefitId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'unauthenticated',
        );
      }
      
      await _supabaseClient
          .from(_redeemedBenefitsTable)
          .update({
            'status': 'cancelled',
          })
          .eq('id', redeemedBenefitId)
          .eq('user_id', userId);
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao cancelar benefício',
        originalError: e,
      );
    }
  }
  
  @override
  Future<RedeemedBenefit?> updateBenefitStatus(String redeemedBenefitId, RedemptionStatus newStatus) async {
    try {
      // Verificar se é usuário está autenticado
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'unauthenticated', 
        );
      }
      
      // Verificar se é admin ou dono do benefício
      final isUserAdmin = await isAdmin();
      
      if (!isUserAdmin) {
        // Verificar se o benefício pertence ao usuário
        final benefit = await _supabaseClient
            .from(_redeemedBenefitsTable)
            .select('user_id')
            .eq('id', redeemedBenefitId)
            .maybeSingle();
            
        if (benefit == null || benefit['user_id'] != userId) {
          throw app_errors.AppAuthException(
            message: 'Permissão negada. Você não pode atualizar este benefício.',
            code: 'permission_denied',
          );
        }
      }
      
      // Converter enum para string
      final statusStr = newStatus.toString().split('.').last;
      
      // Atualizar status do benefício
      final response = await _supabaseClient
          .from(_redeemedBenefitsTable)
          .update({
            'status': statusStr,
          })
          .eq('id', redeemedBenefitId)
          .select()
          .single();
      
      return RedeemedBenefit.fromJson(response);
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao atualizar status do benefício',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<String>> getBenefitCategories() async {
    try {
      final response = await _supabaseClient
          .from(_benefitsTable)
          .select('category')
          .order('category');
      
      // Extrair categorias únicas
      final Set<String> uniqueCategories = {};
      for (final item in response) {
        if (item['category'] != null) {
          uniqueCategories.add(item['category']);
        }
      }
      
      return uniqueCategories.toList();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao buscar categorias',
        originalError: e,
      );
    }
  }
  
  @override
  Future<bool> hasEnoughPoints(String benefitId) async {
    // Implementação simplificada para exemplo
    // Em uma implementação real, verificaria pontos do usuário
    return true;
  }
  
  @override
  Future<List<Benefit>> getFeaturedBenefits() async {
    try {
      final response = await _supabaseClient
          .from(_benefitsTable)
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false);
      
      return response.map((json) => Benefit.fromJson(json)).toList();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao buscar benefícios em destaque',
        originalError: e,
      );
    }
  }
  
  // MÉTODOS DE ADMINISTRAÇÃO
  
  @override
  Future<bool> isAdmin() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return false;
      
      final response = await _supabaseClient
          .from(_usersTable)
          .select('is_admin')
          .eq('id', userId)
          .maybeSingle();
      
      return response != null && response['is_admin'] == true;
    } catch (e) {
      // Em caso de erro, considera que não é admin por segurança
      return false;
    }
  }
  
  @override
  Future<Benefit?> updateBenefitExpiration(String benefitId, DateTime? newExpirationDate) async {
    try {
      // Verificar se é admin
      if (!await isAdmin()) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Apenas administradores podem atualizar datas de expiração.',
          code: 'permission_denied',
        );
      }
      
      final response = await _supabaseClient
          .from(_benefitsTable)
          .update({
            'expires_at': newExpirationDate?.toIso8601String(),
          })
          .eq('id', benefitId)
          .select()
          .maybeSingle();
      
      if (response == null) return null;
      
      return Benefit.fromJson(response);
    } catch (e) {
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar data de expiração',
        originalError: e,
      );
    }
  }
  
  @override
  Future<RedeemedBenefit?> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime? newExpirationDate) async {
    try {
      // Verificar se é admin
      if (!await isAdmin()) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Apenas administradores podem estender a validade de benefícios resgatados.',
          code: 'permission_denied',
        );
      }
      
      // Buscar benefício atual para verificar status
      final currentBenefit = await _supabaseClient
          .from(_redeemedBenefitsTable)
          .select()
          .eq('id', redeemedBenefitId)
          .maybeSingle();
      
      if (currentBenefit == null) {
        return null;
      }
      
      // Se estiver expirado e receber nova data no futuro, reativar
      String status = currentBenefit['status'];
      if (currentBenefit['status'] == 'expired' && 
          newExpirationDate != null && 
          newExpirationDate.isAfter(DateTime.now())) {
        status = 'active';
      }
      
      // Atualizar benefício
      final response = await _supabaseClient
          .from(_redeemedBenefitsTable)
          .update({
            'expires_at': newExpirationDate?.toIso8601String(),
            'status': status,
          })
          .eq('id', redeemedBenefitId)
          .select()
          .single();
      
      return RedeemedBenefit.fromJson(response);
    } catch (e) {
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao estender validade do benefício',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<RedeemedBenefit>> getAllRedeemedBenefits() async {
    try {
      // Verificar se é admin
      if (!await isAdmin()) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Apenas administradores podem ver todos os benefícios resgatados.',
          code: 'permission_denied',
        );
      }
      
      final response = await _supabaseClient
          .from(_redeemedBenefitsTable)
          .select()
          .order('redeemed_at', ascending: false);
      
      return response.map((json) => RedeemedBenefit.fromJson(json)).toList();
    } catch (e) {
      if (e is app_errors.AppException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao buscar todos os benefícios resgatados',
        originalError: e,
      );
    }
  }
  
  /// Gera um código de resgate aleatório
  String _generateRedemptionCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch % chars.length;
    final buffer = StringBuffer();
    
    // Adiciona prefixo
    buffer.write('RAY');
    
    // Adiciona timestamp codificado (6 caracteres)
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    buffer.write(timestamp.substring(timestamp.length - 6));
    
    // Adiciona 3 caracteres aleatórios
    for (int i = 0; i < 3; i++) {
      buffer.write(chars[(random + i) % chars.length]);
    }
    
    return buffer.toString();
  }
  
  /// Sincroniza os dados que podem ter sido alterados durante o modo offline
  Future<void> syncOfflineData() async {
    try {
      // Verificar se há conexão
      if (!_connectivityService.hasConnection) {
        return;
      }
      
      // Sincronizar dados pendentes
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return;
      }
      
      // Atualizar caches principais
      await getBenefits();
      await getRedeemedBenefits();
      await getBenefitCategories();
      await getFeaturedBenefits();
      
      LogUtils.info(
        'Sincronização de dados offline concluída',
        tag: 'BenefitRepository',
      );
    } catch (e) {
      LogUtils.error(
        'Erro ao sincronizar dados offline',
        error: e,
        tag: 'BenefitRepository',
      );
    }
  }
} 
