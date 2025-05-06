// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';

/// Interface do repositório para consumo de água
abstract class WaterIntakeRepository {
  /// Obtém o registro de consumo de água do dia atual
  Future<WaterIntake> getTodayWaterIntake();
  
  /// Adiciona um copo de água ao consumo do dia
  Future<WaterIntake> addGlass();
  
  /// Remove um copo de água do consumo do dia
  Future<WaterIntake> removeGlass();
  
  /// Atualiza a meta diária de copos
  Future<WaterIntake> updateDailyGoal(int newGoal);
}

/// Implementação mock do repositório para desenvolvimento
class MockWaterIntakeRepository implements WaterIntakeRepository {
  WaterIntake? _todayIntake;
  
  @override
  Future<WaterIntake> getTodayWaterIntake() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_todayIntake == null) {
      // Criar um registro para hoje se não existir
      _todayIntake = WaterIntake(
        id: 'water-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user123',
        date: DateTime.now(),
        currentGlasses: 5, // Já consumiu 5 copos (para demonstração)
        dailyGoal: 8,
        createdAt: DateTime.now(),
      );
    }
    
    return _todayIntake!;
  }

  @override
  Future<WaterIntake> addGlass() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Garantir que temos um registro para hoje
    final intake = await getTodayWaterIntake();
    
    // Incrementar o contador de copos
    _todayIntake = intake.copyWith(
      currentGlasses: intake.currentGlasses + 1,
      updatedAt: DateTime.now(),
    );
    
    return _todayIntake!;
  }

  @override
  Future<WaterIntake> removeGlass() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Garantir que temos um registro para hoje
    final intake = await getTodayWaterIntake();
    
    // Não permitir valores negativos
    if (intake.currentGlasses <= 0) {
      return intake;
    }
    
    // Decrementar o contador de copos
    _todayIntake = intake.copyWith(
      currentGlasses: intake.currentGlasses - 1,
      updatedAt: DateTime.now(),
    );
    
    return _todayIntake!;
  }

  @override
  Future<WaterIntake> updateDailyGoal(int newGoal) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Garantir que temos um registro para hoje
    final intake = await getTodayWaterIntake();
    
    // Não permitir valores negativos ou zero
    if (newGoal <= 0) {
      throw ValidationException(
        message: 'A meta diária deve ser maior que zero',
        code: 'invalid_goal',
      );
    }
    
    // Atualizar a meta diária
    _todayIntake = intake.copyWith(
      dailyGoal: newGoal,
      updatedAt: DateTime.now(),
    );
    
    return _todayIntake!;
  }
}

/// Implementação com Supabase
class SupabaseWaterIntakeRepository implements WaterIntakeRepository {
  final SupabaseClient _supabaseClient;

  SupabaseWaterIntakeRepository(this._supabaseClient);

  @override
  Future<WaterIntake> getTodayWaterIntake() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Tentar buscar o registro de hoje
      final response = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      
      if (response != null) {
        return WaterIntake.fromJson(response);
      }
      
      // Se não existir, criar um novo registro
      final newIntake = WaterIntake(
        id: 'temp', // Será substituído pelo ID gerado pelo Supabase
        userId: userId,
        date: today,
        currentGlasses: 0,
        dailyGoal: 8, // Valor padrão
        createdAt: today,
      );
      
      final inserted = await _supabaseClient
          .from('water_intake')
          .insert(newIntake.toJson())
          .select()
          .single();
      
      return WaterIntake.fromJson(inserted);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockWaterIntakeRepository().getTodayWaterIntake();
    }
  }

  @override
  Future<WaterIntake> addGlass() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Primeiro, buscar o registro atual
      final intake = await getTodayWaterIntake();
      
      // Atualizar o contador de copos
      final updated = await _supabaseClient
          .from('water_intake')
          .update({
            'current_glasses': intake.currentGlasses + 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', intake.id)
          .select()
          .single();
      
      return WaterIntake.fromJson(updated);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao adicionar copo de água: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<WaterIntake> removeGlass() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Primeiro, buscar o registro atual
      final intake = await getTodayWaterIntake();
      
      // Não permitir valores negativos
      if (intake.currentGlasses <= 0) {
        return intake;
      }
      
      // Atualizar o contador de copos
      final updated = await _supabaseClient
          .from('water_intake')
          .update({
            'current_glasses': intake.currentGlasses - 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', intake.id)
          .select()
          .single();
      
      return WaterIntake.fromJson(updated);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao remover copo de água: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<WaterIntake> updateDailyGoal(int newGoal) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Não permitir valores negativos ou zero
      if (newGoal <= 0) {
        throw ValidationException(
          message: 'A meta diária deve ser maior que zero',
          code: 'invalid_goal',
        );
      }
      
      // Primeiro, buscar o registro atual
      final intake = await getTodayWaterIntake();
      
      // Atualizar a meta diária
      final updated = await _supabaseClient
          .from('water_intake')
          .update({
            'daily_goal': newGoal,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', intake.id)
          .select()
          .single();
      
      return WaterIntake.fromJson(updated);
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao atualizar meta diária: ${e.toString()}',
        originalError: e,
      );
    }
  }
}

/// Provider para o repositório de consumo de água
final waterIntakeRepositoryProvider = Provider<WaterIntakeRepository>((ref) {
  // Em desenvolvimento, usar o repositório mock
  return MockWaterIntakeRepository();
  
  // Quando estiver pronto para produção:
  // final supabase = Supabase.instance.client;
  // return SupabaseWaterIntakeRepository(supabase);
}); 