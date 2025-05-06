// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import 'package:ray_club_app/features/workout/models/workout_record.dart';

/// Interface para o repositório de registros de treinos
abstract class WorkoutRecordRepository {
  /// Obtém todos os registros de treino do usuário atual
  Future<List<WorkoutRecord>> getUserWorkoutRecords();
  
  /// Cria um novo registro de treino
  Future<WorkoutRecord> createWorkoutRecord(WorkoutRecord record);
  
  /// Atualiza um registro de treino existente
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record);
  
  /// Exclui um registro de treino
  Future<void> deleteWorkoutRecord(String id);
}

/// Implementação mock do repositório para desenvolvimento
class MockWorkoutRecordRepository implements WorkoutRecordRepository {
  @override
  Future<List<WorkoutRecord>> getUserWorkoutRecords() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      return _getMockWorkoutRecords();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar registros de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> createWorkoutRecord(WorkoutRecord record) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // Em um ambiente real, o ID seria gerado pelo backend
      return record.copyWith(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Verificar se o registro existe
      final allRecords = _getMockWorkoutRecords();
      final exists = allRecords.any((r) => r.id == record.id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado para atualização',
          code: 'record_not_found',
        );
      }
      
      return record;
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteWorkoutRecord(String id) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      // Verificar se o registro existe
      final allRecords = _getMockWorkoutRecords();
      final exists = allRecords.any((record) => record.id == id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado para exclusão',
          code: 'record_not_found',
        );
      }
      
      // Em um ambiente real, o registro seria removido do banco de dados
      return;
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }

  // TEMPORÁRIO: Método para gerar dados mockados
  List<WorkoutRecord> _getMockWorkoutRecords() {
    final now = DateTime.now();
    
    return [
      WorkoutRecord(
        id: '1',
        userId: 'user123',
        workoutId: '1',
        workoutName: 'Yoga para Iniciantes',
        workoutType: 'Yoga',
        date: now.subtract(const Duration(days: 1)),
        durationMinutes: 20,
        isCompleted: true,
        notes: 'Senti melhora na flexibilidade',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      WorkoutRecord(
        id: '2',
        userId: 'user123',
        workoutId: '4',
        workoutName: 'Treino de Força Total',
        workoutType: 'Força',
        date: now.subtract(const Duration(days: 3)),
        durationMinutes: 45,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      WorkoutRecord(
        id: '3',
        userId: 'user123',
        workoutId: '3',
        workoutName: 'HIIT 15 minutos',
        workoutType: 'HIIT',
        date: now.subtract(const Duration(days: 5)),
        durationMinutes: 15,
        isCompleted: true,
        notes: 'Muito intenso, próxima vez diminuir o ritmo',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      WorkoutRecord(
        id: '4',
        userId: 'user123',
        workoutId: '5',
        workoutName: 'Yoga Flow',
        workoutType: 'Yoga',
        date: now.subtract(const Duration(days: 7)),
        durationMinutes: 40,
        isCompleted: false,
        notes: 'Parei na metade por dor nas costas',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      WorkoutRecord(
        id: '5',
        userId: 'user123',
        workoutId: null,
        workoutName: 'Corrida ao ar livre',
        workoutType: 'Cardio',
        date: now.subtract(const Duration(days: 10)),
        durationMinutes: 25,
        isCompleted: true,
        notes: 'Corrida no parque, 3km',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      WorkoutRecord(
        id: '6',
        userId: 'user123',
        workoutId: '2',
        workoutName: 'Pilates Abdominal',
        workoutType: 'Pilates',
        date: now.subtract(const Duration(days: 14)),
        durationMinutes: 30,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      // Registro de mês anterior
      WorkoutRecord(
        id: '7',
        userId: 'user123',
        workoutId: '1',
        workoutName: 'Yoga para Iniciantes',
        workoutType: 'Yoga',
        date: now.subtract(const Duration(days: 45)),
        durationMinutes: 20,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
    ];
  }
}

/// Implementação real do repositório usando Supabase
class SupabaseWorkoutRecordRepository implements WorkoutRecordRepository {
  final SupabaseClient _supabaseClient;

  SupabaseWorkoutRecordRepository(this._supabaseClient);

  @override
  Future<List<WorkoutRecord>> getUserWorkoutRecords() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final response = await _supabaseClient
          .from('workout_records')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      
      return response.map((json) => WorkoutRecord.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar registros de treino do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      if (e is app_errors.AppAuthException) rethrow;
      
      // Em desenvolvimento, usar dados mockados em caso de erro
      return MockWorkoutRecordRepository().getUserWorkoutRecords();
    }
  }
  
  @override
  Future<WorkoutRecord> createWorkoutRecord(WorkoutRecord record) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Garantir que o userId do registro corresponde ao usuário atual
      final recordWithUserId = record.copyWith(userId: userId);
      
      final recordMap = recordWithUserId.toJson();
      // Remover o ID para que o Supabase gere um novo
      recordMap.remove('id');
      
      final response = await _supabaseClient
          .from('workout_records')
          .insert(recordMap)
          .select()
          .single();
      
      return WorkoutRecord.fromJson(response);
    } on PostgrestException catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar registro de treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      if (e is app_errors.AppAuthException) rethrow;
      
      // Em desenvolvimento, usar dados mockados em caso de erro
      return MockWorkoutRecordRepository().createWorkoutRecord(record);
    }
  }
  
  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se o registro pertence ao usuário atual
      if (record.userId != userId) {
        throw app_errors.UnauthorizedException(
          message: 'Não autorizado a atualizar este registro',
          code: 'unauthorized',
        );
      }
      
      final recordMap = record.toJson();
      
      final response = await _supabaseClient
          .from('workout_records')
          .update(recordMap)
          .eq('id', record.id)
          .select()
          .single();
      
      return WorkoutRecord.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado para atualização',
          originalError: e,
          code: 'record_not_found',
        );
      }
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      if (e is app_errors.AppAuthException || e is app_errors.UnauthorizedException || e is app_errors.NotFoundException) rethrow;
      
      // Em desenvolvimento, usar dados mockados em caso de erro
      return MockWorkoutRecordRepository().updateWorkoutRecord(record);
    }
  }
  
  @override
  Future<void> deleteWorkoutRecord(String id) async {
    try {
      await _supabaseClient.from('workout_records').delete().eq('id', id);
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }
}

/// Provider para o repositório de registros de treino
final workoutRecordRepositoryProvider = Provider<WorkoutRecordRepository>((ref) {
  // Em desenvolvimento, usar o repositório mock
  return MockWorkoutRecordRepository();
  
  // Em produção:
  // final supabase = Supabase.instance.client;
  // return SupabaseWorkoutRecordRepository(supabase);
}); 