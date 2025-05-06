// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'redeemed_benefit_model.freezed.dart';
part 'redeemed_benefit_model.g.dart';

/// Status possíveis para um benefício resgatado
enum BenefitStatus {
  active, // Benefício ativo e disponível para uso
  used, // Benefício já utilizado
  expired, // Benefício expirado sem ter sido utilizado
}

/// Modelo que representa um benefício resgatado pelo usuário
@freezed
class RedeemedBenefit with _$RedeemedBenefit {
  const factory RedeemedBenefit({
    /// ID único do benefício resgatado
    required String id,
    
    /// ID do usuário que resgatou
    required String userId,
    
    /// ID do benefício original
    required String benefitId,
    
    /// Título do benefício
    required String title,
    
    /// Descrição do benefício
    required String description,
    
    /// URL da imagem/logo do benefício (opcional)
    String? logoUrl,
    
    /// Código do benefício (para uso/resgate)
    required String code,
    
    /// Status atual do benefício
    required BenefitStatus status,
    
    /// Data de expiração do benefício
    required DateTime expirationDate,
    
    /// Data em que o benefício foi resgatado
    required DateTime redeemedAt,
    
    /// Data em que o benefício foi utilizado
    DateTime? usedAt,
    
    /// Data de criação do registro
    required DateTime createdAt,
    
    /// Data da última atualização
    DateTime? updatedAt,
  }) = _RedeemedBenefit;

  /// Cria um RedeemedBenefit a partir de um mapa JSON
  factory RedeemedBenefit.fromJson(Map<String, dynamic> json) => _$RedeemedBenefitFromJson(json);
  
  const RedeemedBenefit._();
  
  /// Verifica se o benefício está expirado
  bool get isExpired => status == BenefitStatus.expired || 
    (status == BenefitStatus.active && DateTime.now().isAfter(expirationDate));
  
  /// Verifica se o benefício ainda pode ser usado
  bool get canBeUsed => status == BenefitStatus.active && 
    DateTime.now().isBefore(expirationDate);
  
  /// Retorna os dias restantes até a expiração
  int get daysUntilExpiration {
    final now = DateTime.now();
    if (now.isAfter(expirationDate)) return 0;
    return expirationDate.difference(now).inDays;
  }
  
  /// Retorna uma string amigável com o status do benefício
  String get statusText {
    switch (status) {
      case BenefitStatus.active: 
        return 'Ativo';
      case BenefitStatus.used: 
        return 'Utilizado';
      case BenefitStatus.expired: 
        return 'Expirado';
    }
  }
} 