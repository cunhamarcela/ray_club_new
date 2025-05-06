// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../enums/benefit_type.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit.dart';
import 'mock_benefit_repository.dart';

/// Provider para o repositório de benefícios
final benefitsRepositoryProvider = Provider<BenefitsRepository>((ref) {
  return MockBenefitRepository();
});

/// Interface para o repositório de benefícios
abstract class BenefitsRepository {
  /// Obtém todos os benefícios disponíveis
  Future<List<Benefit>> getAllBenefits();
  
  /// Obtém benefícios por tipo
  Future<List<Benefit>> getBenefitsByType(BenefitType type);
  
  /// Obtém benefícios por parceiro
  Future<List<Benefit>> getBenefitsByPartner(String partner);
  
  /// Obtém um benefício pelo ID
  Future<Benefit?> getBenefitById(String id);
  
  /// Resgata um benefício
  Future<RedeemedBenefit> redeemBenefit(String benefitId);
  
  /// Obtém todos os benefícios resgatados pelo usuário
  Future<List<RedeemedBenefit>> getRedeemedBenefits();
  
  /// Obtém um benefício resgatado pelo ID
  Future<RedeemedBenefit?> getRedeemedBenefitById(String id);
  
  /// Atualiza o status de um benefício resgatado
  Future<RedeemedBenefit?> updateBenefitStatus(String redeemedBenefitId, RedemptionStatus newStatus);
  
  /// Marca um benefício como utilizado
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId);
  
  /// Cancela um benefício resgatado
  Future<void> cancelRedeemedBenefit(String redeemedBenefitId);
  
  /// Verifica se o usuário atual é um administrador
  Future<bool> isCurrentUserAdmin();
  
  /// Obtém todos os benefícios (método legado)
  Future<List<Benefit>> getBenefits();
  
  /// Obtém categorias de benefícios
  Future<List<String>> getBenefitCategories();
  
  /// Verifica se o usuário tem pontos suficientes para resgatar o benefício
  Future<bool> hasEnoughPoints(String benefitId);
  
  /// Obtém a quantidade de pontos do usuário atual
  Future<int> getUserPoints();
} 