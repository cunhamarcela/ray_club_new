// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';

/// Provider para o repositório do dashboard
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return DashboardRepository(supabaseClient);
});

/// Classe responsável por acessar dados do dashboard no Supabase
class DashboardRepository {
  /// Cliente Supabase para comunicação com o backend
  final SupabaseClient _client;
  
  /// Construtor da classe
  DashboardRepository(this._client);

  /// Obtém os dados do dashboard a partir do Supabase
  /// [userId] - ID do usuário para buscar os dados
  Future<DashboardData> getDashboardData(String userId) async {
    try {
      // Use the single database function call instead of multiple queries
      final response = await _client
          .rpc('get_dashboard_data', params: {'user_id_param': userId});
      
      // Extract user progress from the response
      Map<String, dynamic> userProgressData;
      if (response['user_progress'] != null && response['user_progress'] is Map<String, dynamic>) {
        userProgressData = response['user_progress'] as Map<String, dynamic>;
      } else {
        // Fallback para um objeto vazio se user_progress for nulo
        userProgressData = {
          'id': '',
          'user_id': userId,
          'total_workouts': 0,
          'current_streak': 0,
          'longest_streak': 0,
          'total_points': 0,
          'days_trained_this_month': 0,
          'workout_types': {},
        };
      }
      final userProgress = UserProgress.fromJson(userProgressData);
      
      // Process challenge data if available
      Challenge? currentChallenge;
      if (response['current_challenge'] != null && response['current_challenge'] is Map<String, dynamic>) {
        try {
          currentChallenge = Challenge.fromJson(response['current_challenge'] as Map<String, dynamic>);
        } catch (e) {
          // Log error but continue - non-fatal error
          print('Erro ao processar desafio atual: $e');
        }
      }
      
      // Process challenge progress if available
      ChallengeProgress? challengeProgress;
      if (response['challenge_progress'] != null && response['challenge_progress'] is Map<String, dynamic>) {
        try {
          challengeProgress = ChallengeProgress.fromJson(response['challenge_progress'] as Map<String, dynamic>);
        } catch (e) {
          // Log error but continue - non-fatal error
          print('Erro ao processar progresso do desafio: $e');
        }
      }
      
      // Process redeemed benefits if available
      List<RedeemedBenefit> redeemedBenefits = [];
      if (response['redeemed_benefits'] != null && response['redeemed_benefits'] is List) {
        final benefitsJson = response['redeemed_benefits'] as List<dynamic>;
        redeemedBenefits = benefitsJson
            .where((json) => json is Map<String, dynamic>)
            .map((json) {
              try {
                return RedeemedBenefit.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('Erro ao processar benefício resgatado: $e');
                return null;
              }
            })
            .where((benefit) => benefit != null)
            .cast<RedeemedBenefit>()
            .toList();
      }
      
      // Additional data includes water intake, goals, and recent workouts
      final additionalData = <String, dynamic>{};
      
      // Include water intake data
      if (response['water_intake'] != null && response['water_intake'] is Map<String, dynamic>) {
        additionalData['water_intake'] = response['water_intake'] as Map<String, dynamic>;
      }
      
      // Include goals data
      if (response['goals'] != null && response['goals'] is List) {
        additionalData['goals'] = response['goals'] as List<dynamic>;
      }
      
      // Include recent workouts data
      if (response['recent_workouts'] != null && response['recent_workouts'] is List) {
        additionalData['recent_workouts'] = response['recent_workouts'] as List<dynamic>;
      }
      
      return DashboardData(
        userProgress: userProgress,
        currentChallenge: currentChallenge,
        challengeProgress: challengeProgress,
        redeemedBenefits: redeemedBenefits,
        lastUpdated: DateTime.now(),
        additionalData: additionalData,
      );
    } catch (e, stackTrace) {
      throw AppException(
        message: 'Erro ao buscar dados do dashboard: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Atualiza o progresso de água do usuário
  /// [userId] - ID do usuário
  /// [waterIntakeId] - ID do registro de água
  /// [cups] - Novo número de copos
  Future<void> updateWaterIntake(String userId, String waterIntakeId, int cups) async {
    try {
      // Verificar se o ID é válido
      if (waterIntakeId.trim().isEmpty) {
        throw AppException(
          message: 'ID de registro de água inválido (vazio)',
          code: 'invalid_water_intake_id',
        );
      }
      
      // Verificar se o registro existe antes de atualizar
      final exists = await _client
          .from('water_intake')
          .select('id')
          .eq('id', waterIntakeId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (exists == null) {
        // Se o registro não existir, vamos criar um novo
        debugPrint('⚠️ Registro de água não encontrado, criando um novo...');
        await createWaterIntakeForToday(userId);
        
        // Recarregar e verificar novamente
        final recheck = await _client
            .from('water_intake')
            .select('id')
            .eq('user_id', userId)
            .eq('date', _getTodayFormatted())
            .maybeSingle();
        
        if (recheck == null) {
          throw AppException(
            message: 'Falha ao criar registro de água',
            code: 'water_intake_create_failed',
          );
        }
        
        // Usar o ID do novo registro
        waterIntakeId = recheck['id'] as String;
      }
      
      // Agora podemos atualizar com segurança
      await _client
          .from('water_intake')
          .update({
            'cups': cups,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', waterIntakeId)
          .eq('user_id', userId);
      
      debugPrint('✅ Registro de água atualizado com sucesso: $cups copos');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao atualizar água: $e');
      throw AppException(
        message: 'Erro ao atualizar ingestão de água: ${e.toString()}',
        stackTrace: stackTrace,
        code: 'water_intake_update_error',
      );
    }
  }
  
  /// Retorna a data de hoje formatada para o Supabase
  String _getTodayFormatted() {
    final today = DateTime.now();
    return "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }
  
  /// Cria um novo registro de água para o dia atual se não existir
  /// [userId] - ID do usuário
  Future<String?> createWaterIntakeForToday(String userId) async {
    try {
      final today = DateTime.now();
      final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      // Verificar se já existe um registro para hoje
      final existing = await _client
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', formattedDate)
          .maybeSingle();
      
      // Se já existe, retornar o ID do registro existente
      if (existing != null) {
        return existing['id'] as String?;
      }
      
      // Não incluir o ID e deixar o Supabase gerar automaticamente
      final insertData = {
        'user_id': userId,
        'date': formattedDate,
        'cups': 0,
        'goal': 8,
        'glass_size': 250,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _client
          .from('water_intake')
          .insert(insertData)
          .select()
          .single();
      
      return response['id'] as String?;
    } catch (e) {
      debugPrint('Error getting water intake: $e');
      throw AppException(
        message: 'Erro ao buscar registro de água: $e',
        code: 'water_intake_error',
      );
    }
  }
} 