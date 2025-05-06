// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';

part 'dashboard_data.freezed.dart';
part 'dashboard_data.g.dart';

/// Modelo que representa os dados completos do dashboard do usuário
@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    /// Progresso do usuário
    required UserProgress userProgress,
    
    /// Data da última atualização dos dados
    required DateTime lastUpdated,
    
    /// Desafio atual do usuário (se houver)
    Challenge? currentChallenge,
    
    /// Progresso do desafio atual (se houver)
    ChallengeProgress? challengeProgress,
    
    /// Lista de benefícios resgatados
    @Default([]) List<RedeemedBenefit> redeemedBenefits,
    
    /// Mapa com dados adicionais (consumo de água, metas, etc.)
    @Default({}) Map<String, dynamic> additionalData,
  }) = _DashboardData;

  /// Conversor de JSON para DashboardData
  factory DashboardData.fromJson(Map<String, dynamic> json) => _$DashboardDataFromJson(json);
  
  /// Cria uma instância vazia para inicialização
  factory DashboardData.empty() => DashboardData(
    userProgress: UserProgress.empty(),
    lastUpdated: DateTime.now(),
  );
} 