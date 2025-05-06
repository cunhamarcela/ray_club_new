// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../core/errors/app_exception.dart' as app_errors;
import '../enums/benefit_type.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit.dart';
import 'benefit_repository.dart';
import 'benefits_repository.dart';

/// Implementação mock do BenefitRepository para testes e desenvolvimento
class MockBenefitRepository implements BenefitRepository, BenefitsRepository {
  final List<Benefit> _mockBenefits = [];
  final List<RedeemedBenefit> _mockRedeemedBenefits = [];
  final Uuid _uuid = const Uuid();
  
  // Mock de pontos do usuário para testes
  int _userPoints = 500;
  
  MockBenefitRepository() {
    _initMockData();
  }
  
  void _initMockData() {
    // Parceiros
    final partners = [
      'Ray Gym', 'NutriFood', 'ZenMind', 'EcoStore', 'SportGear'
    ];
    
    // Preenche dados mock de benefícios
    for (int i = 0; i < 15; i++) {
      final partner = partners[i % partners.length];
      final type = i % 3 == 0 ? BenefitType.qrCode : 
                  i % 3 == 1 ? BenefitType.coupon : BenefitType.link;
      
      _mockBenefits.add(Benefit(
        id: _uuid.v4(),
        title: 'Benefício ${i + 1}',
        description: 'Descrição detalhada do benefício ${i + 1} oferecido por $partner.',
        imageUrl: 'https://via.placeholder.com/300x200.png?text=Benefit+${i + 1}',
        partner: partner,
        expiresAt: i % 3 == 0 ? DateTime.now().add(Duration(days: 30 + i)) : null,
        terms: 'Termos e condições aplicáveis. Oferta válida enquanto durar o estoque.',
        type: type,
        actionUrl: i % 2 == 0 ? 'https://example.com/benefit/$i' : null,
        qrCodeUrl: type == BenefitType.qrCode ? 'https://via.placeholder.com/300x300.png?text=QR+Code+${i + 1}' : null,
        pointsRequired: 100 + (i * 50),
        expirationDate: DateTime.now().add(Duration(days: 30 + i)),
        availableQuantity: 10 - (i % 5),
        termsAndConditions: 'Termos e condições detalhados para o benefício ${i + 1}. Válido para uso único.',
      ));
    }
    
    // Adiciona alguns benefícios já resgatados pelo usuário
    _mockRedeemedBenefits.add(RedeemedBenefit(
      id: _uuid.v4(),
      benefitId: _mockBenefits[0].id,
      userId: 'mock_user_id',
      redeemedAt: DateTime.now().subtract(const Duration(days: 5)),
      redemptionCode: 'RED${_randomCode(6)}',
      status: RedemptionStatus.active,
      benefitSnapshot: _mockBenefits[0],
    ));
    
    _mockRedeemedBenefits.add(RedeemedBenefit(
      id: _uuid.v4(),
      benefitId: _mockBenefits[1].id,
      userId: 'mock_user_id',
      redeemedAt: DateTime.now().subtract(const Duration(days: 10)),
      redemptionCode: 'RED${_randomCode(6)}',
      status: RedemptionStatus.used,
      usedAt: DateTime.now().subtract(const Duration(days: 8)),
      benefitSnapshot: _mockBenefits[1],
    ));
    
    _mockRedeemedBenefits.add(RedeemedBenefit(
      id: _uuid.v4(),
      benefitId: _mockBenefits[2].id,
      userId: 'mock_user_id',
      redeemedAt: DateTime.now().subtract(const Duration(days: 30)),
      redemptionCode: 'RED${_randomCode(6)}',
      status: RedemptionStatus.expired,
      expiresAt: DateTime.now().subtract(const Duration(days: 5)),
      benefitSnapshot: _mockBenefits[2],
    ));
  }
  
  // Gera código aleatório para simulação
  String _randomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
  
  // Simula atraso de rede para tornar o mock mais realista
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(700)));
  }

  @override
  Future<List<Benefit>> getBenefits() async {
    await _simulateNetworkDelay();
    return List.of(_mockBenefits);
  }

  @override
  Future<List<Benefit>> getAllBenefits() async {
    return getBenefits();
  }

  @override
  Future<List<Benefit>> getBenefitsByType(BenefitType type) async {
    await _simulateNetworkDelay();
    return _mockBenefits.where((benefit) => benefit.type == type).toList();
  }

  @override
  Future<List<Benefit>> getBenefitsByPartner(String partner) async {
    await _simulateNetworkDelay();
    return _mockBenefits.where((benefit) => benefit.partner == partner).toList();
  }

  @override
  Future<Benefit?> getBenefitById(String id) async {
    await _simulateNetworkDelay();
    try {
      return _mockBenefits.firstWhere((benefit) => benefit.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<RedeemedBenefit> redeemBenefit(String benefitId) async {
    await _simulateNetworkDelay();
    
    final benefit = await getBenefitById(benefitId);
    if (benefit == null) {
      throw app_errors.StorageException(
        message: 'Benefício não encontrado',
        code: 'benefit_not_found',
      );
    }
    
    // Como o modelo não tem mais pointsRequired, usamos um valor fixo para simulação
    final int simulatedPointsRequired = 100;
    
    // Verifica se o usuário tem pontos suficientes
    if (_userPoints < simulatedPointsRequired) {
      throw app_errors.ValidationException(
        message: 'Pontos insuficientes para resgatar este benefício',
        code: 'insufficient_points',
      );
    }
    
    // Verifica se não está expirado
    if (benefit.expiresAt != null && benefit.expiresAt!.isBefore(DateTime.now())) {
      throw app_errors.ValidationException(
        message: 'Este benefício expirou',
        code: 'benefit_expired',
      );
    }
    
    // Subtrai pontos do usuário
    _userPoints -= simulatedPointsRequired;
    
    // Define data de expiração padrão (30 dias)
    final expiresAt = DateTime.now().add(const Duration(days: 30));
    
    // Cria registro de benefício resgatado
    final redeemedBenefit = RedeemedBenefit(
      id: _uuid.v4(),
      benefitId: benefitId,
      userId: 'mock_user_id', 
      redeemedAt: DateTime.now(),
      redemptionCode: 'RED${_randomCode(6)}',
      status: RedemptionStatus.active,
      expiresAt: expiresAt,
      benefitSnapshot: benefit,
    );
    
    _mockRedeemedBenefits.add(redeemedBenefit);
    return redeemedBenefit;
  }

  @override
  Future<List<RedeemedBenefit>> getRedeemedBenefits() async {
    await _simulateNetworkDelay();
    return List.of(_mockRedeemedBenefits);
  }

  @override
  Future<RedeemedBenefit?> getRedeemedBenefitById(String id) async {
    await _simulateNetworkDelay();
    try {
      return _mockRedeemedBenefits.firstWhere((redeemed) => redeemed.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<RedeemedBenefit?> updateBenefitStatus(String redeemedBenefitId, RedemptionStatus newStatus) async {
    await _simulateNetworkDelay();
    
    final index = _mockRedeemedBenefits.indexWhere((redeemed) => redeemed.id == redeemedBenefitId);
    if (index < 0) {
      return null;
    }
    
    // Atualiza o status do benefício
    final updatedBenefit = _mockRedeemedBenefits[index].copyWith(status: newStatus);
    _mockRedeemedBenefits[index] = updatedBenefit;
    
    return updatedBenefit;
  }

  @override
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId) async {
    await _simulateNetworkDelay();
    
    final index = _mockRedeemedBenefits.indexWhere((b) => b.id == redeemedBenefitId);
    if (index < 0) {
      throw app_errors.StorageException(
        message: 'Benefício resgatado não encontrado',
        code: 'redeemed_benefit_not_found',
      );
    }
    
    // Verifica se o benefício está ativo
    if (_mockRedeemedBenefits[index].status != RedemptionStatus.active) {
      throw app_errors.ValidationException(
        message: 'Este benefício não está ativo',
        code: 'benefit_not_active',
      );
    }
    
    // Atualiza status para usado
    final updated = _mockRedeemedBenefits[index].copyWith(
      status: RedemptionStatus.used,
      usedAt: DateTime.now(),
    );
    
    _mockRedeemedBenefits[index] = updated;
    return updated;
  }

  @override
  Future<void> cancelRedeemedBenefit(String redeemedBenefitId) async {
    await _simulateNetworkDelay();
    
    final index = _mockRedeemedBenefits.indexWhere((b) => b.id == redeemedBenefitId);
    if (index < 0) {
      throw app_errors.StorageException(
        message: 'Benefício resgatado não encontrado',
        code: 'redeemed_benefit_not_found',
      );
    }
    
    // Verifica se o benefício está ativo (só pode cancelar se estiver ativo)
    if (_mockRedeemedBenefits[index].status != RedemptionStatus.active) {
      throw app_errors.ValidationException(
        message: 'Apenas benefícios ativos podem ser cancelados',
        code: 'benefit_not_active',
      );
    }
    
    // Atualiza o status para cancelado
    _mockRedeemedBenefits[index] = _mockRedeemedBenefits[index].copyWith(
      status: RedemptionStatus.cancelled
    );
    
    // Retorna os pontos para o usuário
    final benefitSnapshot = _mockRedeemedBenefits[index].benefitSnapshot;
    if (benefitSnapshot != null) {
      // Como o modelo não tem mais pointsRequired, usamos um valor fixo
      final int simulatedPointsRequired = 100;
      _userPoints += simulatedPointsRequired;
    }
  }

  @override
  Future<List<String>> getBenefitCategories() async {
    await _simulateNetworkDelay();
    // Extrair categorias únicas dos parceiros
    final categories = <String>{};
    for (var benefit in _mockBenefits) {
      categories.add(benefit.partner);
    }
    return categories.toList();
  }

  @override
  Future<bool> hasEnoughPoints(String benefitId) async {
    await _simulateNetworkDelay();
    
    final benefit = await getBenefitById(benefitId);
    if (benefit == null) {
      return false;
    }
    
    return _userPoints >= benefit.pointsRequired;
  }

  @override
  Future<List<Benefit>> getFeaturedBenefits() async {
    await _simulateNetworkDelay();
    // Como não temos mais isFeatured, selecionar aleatoriamente alguns benefícios
    final random = Random();
    return _mockBenefits.where((_) => random.nextBool()).take(3).toList();
  }
  
  // Método auxiliar para adicionar pontos ao usuário (apenas para testes)
  Future<int> addUserPoints(int points) async {
    _userPoints += points;
    return _userPoints;
  }
  
  // Método auxiliar para obter pontos do usuário atual (apenas para testes)
  Future<int> getUserPoints() async {
    await _simulateNetworkDelay();
    return _userPoints;
  }
  
  // IMPLEMENTAÇÃO DE MÉTODOS DE ADMINISTRAÇÃO
  
  /// Simula o status de admin do usuário atual (para fins de demo)
  bool _isAdminUser = true;
  
  @override
  Future<bool> isAdmin() async {
    await _simulateNetworkDelay();
    return _isAdminUser;
  }
  
  /// Alternar status de admin para testes
  void toggleAdminStatus() {
    _isAdminUser = !_isAdminUser;
  }
  
  @override
  Future<Benefit?> updateBenefitExpiration(String benefitId, DateTime? newExpirationDate) async {
    await _simulateNetworkDelay();
    
    // Verificar se é admin
    if (!await isAdmin()) {
      throw app_errors.AppAuthException(
        message: 'Permissão negada. Apenas administradores podem atualizar datas de expiração.',
        code: 'permission_denied',
      );
    }
    
    final index = _mockBenefits.indexWhere((b) => b.id == benefitId);
    if (index < 0) return null;
    
    final updatedBenefit = _mockBenefits[index].copyWith(expirationDate: newExpirationDate ?? _mockBenefits[index].expirationDate);
    _mockBenefits[index] = updatedBenefit;
    return updatedBenefit;
  }
  
  @override
  Future<RedeemedBenefit?> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime? newExpirationDate) async {
    await _simulateNetworkDelay();
    
    // Verificar se é admin
    if (!await isAdmin()) {
      throw app_errors.AppAuthException(
        message: 'Permissão negada. Apenas administradores podem estender a validade de benefícios resgatados.',
        code: 'permission_denied',
      );
    }
    
    final index = _mockRedeemedBenefits.indexWhere((rb) => rb.id == redeemedBenefitId);
    if (index < 0) {
      return null;
    }
    
    // Se o benefício estiver expirado e estiver recebendo uma nova data, atualizar o status para ativo
    RedemptionStatus newStatus = _mockRedeemedBenefits[index].status;
    if (_mockRedeemedBenefits[index].status == RedemptionStatus.expired && 
        newExpirationDate != null && 
        newExpirationDate.isAfter(DateTime.now())) {
      newStatus = RedemptionStatus.active;
    }
    
    // Atualizar a data de expiração e possivelmente o status
    final updatedBenefit = _mockRedeemedBenefits[index].copyWith(
      expiresAt: newExpirationDate,
      status: newStatus
    );
    
    _mockRedeemedBenefits[index] = updatedBenefit;
    return updatedBenefit;
  }
  
  @override
  Future<List<RedeemedBenefit>> getAllRedeemedBenefits() async {
    await _simulateNetworkDelay();
    
    // Verificar se é admin
    if (!await isAdmin()) {
      throw app_errors.AppAuthException(
        message: 'Permissão negada. Apenas administradores podem ver todos os benefícios resgatados.',
        code: 'permission_denied',
      );
    }
    
    return List.of(_mockRedeemedBenefits);
  }

  @override
  Future<List<Benefit>> getBenefitsByCategory(String category) async {
    await _simulateNetworkDelay();
    return _mockBenefits.where((benefit) => benefit.partner == category).toList();
  }

  @override
  Future<bool> isCurrentUserAdmin() async {
    await _simulateNetworkDelay();
    return _isAdminUser;
  }
} 
