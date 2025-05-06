// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'benefit.dart';

part 'redeemed_benefit.freezed.dart';
part 'redeemed_benefit.g.dart';

/// Representa um benefício que foi resgatado por um usuário.
@freezed
class RedeemedBenefit with _$RedeemedBenefit {
  const factory RedeemedBenefit({
    /// Identificador único do resgate
    required String id,
    
    /// ID do benefício resgatado
    required String benefitId,
    
    /// ID do usuário que resgatou o benefício
    required String userId,
    
    /// Data e hora do resgate
    required DateTime redeemedAt,
    
    /// Código único do benefício resgatado (para verificação)
    required String redemptionCode,
    
    /// Data de expiração do resgate (quando aplicável)
    DateTime? expiresAt,
    
    /// Status do resgate
    @Default(RedemptionStatus.active) RedemptionStatus status,
    
    /// Dados completos do benefício no momento do resgate
    Benefit? benefitSnapshot,
    
    /// Dados adicionais específicos para o resgate
    Map<String, dynamic>? additionalData,
    
    /// Data de uso do benefício (quando foi consumido pelo usuário)
    DateTime? usedAt,
  }) = _RedeemedBenefit;

  /// Cria um RedeemedBenefit a partir de JSON
  factory RedeemedBenefit.fromJson(Map<String, dynamic> json) => _$RedeemedBenefitFromJson(json);
}

/// Status possíveis para um benefício resgatado
enum RedemptionStatus {
  /// Benefício ativo e disponível para uso
  active,
  
  /// Benefício já utilizado pelo usuário
  used,
  
  /// Benefício expirado (passou da data de validade)
  expired,
  
  /// Benefício cancelado (por administrador ou usuário)
  cancelled
} 
