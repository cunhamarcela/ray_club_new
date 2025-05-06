// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import 'package:ray_club_app/features/workout/models/workout_category.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';

/// Interface para o repositório de treinos
abstract class WorkoutRepository {
  /// Obtém todos os treinos
  Future<List<Workout>> getWorkouts();

  /// Obtém treinos por categoria
  Future<List<Workout>> getWorkoutsByCategory(String category);

  /// Obtém um treino específico pelo ID
  Future<Workout> getWorkoutById(String id);
  
  /// Cria um novo treino
  Future<Workout> createWorkout(Workout workout);
  
  /// Atualiza um treino existente
  Future<Workout> updateWorkout(Workout workout);
  
  /// Exclui um treino
  Future<void> deleteWorkout(String id);
  
  /// Obtém todas as categorias de treino
  Future<List<WorkoutCategory>> getWorkoutCategories();
}

/// Implementação mock do repositório para desenvolvimento
class MockWorkoutRepository implements WorkoutRepository {
  @override
  Future<List<Workout>> getWorkouts() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      return _getMockWorkouts();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WorkoutCategory>> getWorkoutCategories() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      return _getMockCategories();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar categorias de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final allWorkouts = _getMockWorkouts();
      return allWorkouts
          .where((workout) => workout.type.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos por categoria',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> getWorkoutById(String id) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final allWorkouts = _getMockWorkouts();
      return allWorkouts.firstWhere(
        (workout) => workout.id == id,
        orElse: () => throw app_errors.NotFoundException(
          message: 'Treino não encontrado',
          code: 'workout_not_found',
        ),
      );
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao carregar treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<Workout> createWorkout(Workout workout) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // Em um ambiente real, o ID seria gerado pelo backend
      return workout.copyWith(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar treino',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> updateWorkout(Workout workout) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Verificar se o treino existe
      final allWorkouts = _getMockWorkouts();
      final exists = allWorkouts.any((w) => w.id == workout.id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado para atualização',
          code: 'workout_not_found',
        );
      }
      
      // Em um ambiente real, o updatedAt seria atualizado
      return workout.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar treino',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      // Verificar se o treino existe
      final allWorkouts = _getMockWorkouts();
      final exists = allWorkouts.any((workout) => workout.id == id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado para exclusão',
          code: 'workout_not_found',
        );
      }
      
      // Em um ambiente real, o treino seria removido do banco de dados
      return;
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao excluir treino',
        originalError: e,
      );
    }
  }

  // TEMPORÁRIO: Método para gerar dados mockados
  List<Workout> _getMockWorkouts() {
    final now = DateTime.now();
    
    return [
      Workout(
        id: '1',
        title: 'Yoga para Iniciantes',
        description: 'Um treino de yoga suave para quem está começando a praticar.',
        imageUrl: 'assets/images/categories/yoga.png',
        type: 'Yoga',
        durationMinutes: 20,
        difficulty: 'Iniciante',
        equipment: ['Tapete', 'Bloco de yoga'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(name: 'Respiração profunda'),
              Exercise(name: 'Alongamento leve'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(name: 'Postura do cachorro olhando para baixo'),
              Exercise(name: 'Postura da montanha'),
              Exercise(name: 'Postura da árvore'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(name: 'Relaxamento final'),
            ],
          ),
        ],
        creatorId: 'instrutor1',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Workout(
        id: '2',
        title: 'Pilates Abdominal',
        description: 'Treino focado no fortalecimento do core e abdômen usando técnicas de pilates.',
        imageUrl: 'assets/images/categories/pilates.png',
        type: 'Pilates',
        durationMinutes: 30,
        difficulty: 'Intermediário',
        equipment: ['Tapete', 'Bola pequena'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(name: 'Respiração de pilates'),
              Exercise(name: 'Mobilidade de coluna'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(name: 'The hundred'),
              Exercise(name: 'Single leg stretch'),
              Exercise(name: 'Double leg stretch'),
              Exercise(name: 'Criss cross'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(name: 'Alongamento de coluna'),
            ],
          ),
        ],
        creatorId: 'instrutor2',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Workout(
        id: '3',
        title: 'HIIT 15 minutos',
        description: 'Treino de alta intensidade para queimar calorias em pouco tempo.',
        imageUrl: 'assets/images/workout_default.jpg',
        type: 'HIIT',
        durationMinutes: 15,
        difficulty: 'Avançado',
        equipment: ['Tapete'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(name: 'Jumping jacks'),
              Exercise(name: 'Corrida no lugar'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(name: 'Burpees'),
              Exercise(name: 'Mountain climbers'),
              Exercise(name: 'Jumping squats'),
              Exercise(name: 'Push-ups'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(name: 'Alongamentos gerais'),
            ],
          ),
        ],
        creatorId: 'instrutor3',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Workout(
        id: '4',
        title: 'Treino de Força Total',
        description: 'Treino completo para ganho de força muscular em todo o corpo.',
        imageUrl: 'assets/images/categories/musculacao.jpg',
        type: 'Musculação',
        durationMinutes: 45,
        difficulty: 'Intermediário',
        equipment: ['Halteres', 'Banco'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(name: 'Mobilidade articular'),
              Exercise(name: 'Ativação muscular'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(name: 'Agachamento com peso'),
              Exercise(name: 'Supino com halteres'),
              Exercise(name: 'Remada'),
              Exercise(name: 'Elevação lateral'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(name: 'Alongamento de peito'),
              Exercise(name: 'Alongamento de costas'),
              Exercise(name: 'Alongamento de pernas'),
            ],
          ),
        ],
        creatorId: 'instrutor4',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Workout(
        id: '5',
        title: 'Yoga Flow',
        description: 'Sequência fluida de posturas de yoga para melhorar flexibilidade e equilíbrio.',
        imageUrl: 'assets/images/categories/yoga.png',
        type: 'Yoga',
        durationMinutes: 40,
        difficulty: 'Intermediário',
        equipment: ['Tapete', 'Bloco de yoga'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(name: 'Saudação ao sol A'),
              Exercise(name: 'Saudação ao sol B'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(name: 'Guerreiro I'),
              Exercise(name: 'Guerreiro II'),
              Exercise(name: 'Triângulo'),
              Exercise(name: 'Meia lua'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(name: 'Postura da criança'),
              Exercise(name: 'Savasana'),
            ],
          ),
        ],
        creatorId: 'instrutor1',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Workout(
        id: '6',
        title: 'HIIT para Iniciantes',
        description: 'Versão mais acessível de HIIT para quem está começando.',
        imageUrl: 'assets/images/workout_default.jpg',
        type: 'HIIT',
        durationMinutes: 20,
        difficulty: 'Iniciante',
        equipment: ['Tapete', 'Garrafa de água como peso'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(name: 'Marcha no lugar'),
              Exercise(name: 'Rotação de tronco'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(name: 'Agachamento simples'),
              Exercise(name: 'Prancha'),
              Exercise(name: 'Elevação de joelhos'),
              Exercise(name: 'Flexão modificada'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(name: 'Alongamento de quadríceps'),
              Exercise(name: 'Alongamento de panturrilhas'),
            ],
          ),
        ],
        creatorId: 'instrutor3',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // TEMPORÁRIO: Método para gerar categorias mockadas
  List<WorkoutCategory> _getMockCategories() {
    return [
      const WorkoutCategory(
        id: 'category-1',
        name: 'Cardio',
        description: 'Treinos para melhorar a saúde cardiovascular e queimar calorias',
        imageUrl: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?q=80&w=1000',
        workoutsCount: 8,
        colorHex: '#FF5252',
      ),
      const WorkoutCategory(
        id: 'category-2',
        name: 'Força',
        description: 'Treinos para desenvolver força muscular e resistência',
        imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=1000',
        workoutsCount: 12,
        colorHex: '#4285F4',
      ),
      const WorkoutCategory(
        id: 'category-3',
        name: 'Yoga',
        description: 'Treinos para melhorar flexibilidade, equilíbrio e reduzir o estresse',
        imageUrl: 'https://images.unsplash.com/photo-1588286840104-8957b019727f?q=80&w=1000',
        workoutsCount: 6,
        colorHex: '#9C27B0',
      ),
      const WorkoutCategory(
        id: 'category-4',
        name: 'Pilates',
        description: 'Treinos focados no core para melhorar postura e força',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1000',
        workoutsCount: 5,
        colorHex: '#009688',
      ),
      const WorkoutCategory(
        id: 'category-5',
        name: 'HIIT',
        description: 'Treinos de alta intensidade para resultados rápidos',
        imageUrl: 'https://images.unsplash.com/photo-1540474527806-6d5091376ce8?q=80&w=1000',
        workoutsCount: 7,
        colorHex: '#FF9800',
      ),
      const WorkoutCategory(
        id: 'category-6',
        name: 'Alongamento',
        description: 'Treinos para melhorar flexibilidade e recuperação muscular',
        imageUrl: 'https://images.unsplash.com/photo-1616699002805-0741e1e4a9c5?q=80&w=1000',
        workoutsCount: 4,
        colorHex: '#4CAF50',
      ),
    ];
  }
}

/// Implementação real do repositório de treinos usando Supabase
class SupabaseWorkoutRepository implements WorkoutRepository {
  final SupabaseClient _supabaseClient;
  
  SupabaseWorkoutRepository(this._supabaseClient);
  
  @override
  Future<List<Workout>> getWorkouts() async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .order('created_at', ascending: false);
          
      return (response as List<dynamic>)
          .map((data) => _mapToWorkout(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar treinos do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WorkoutCategory>> getWorkoutCategories() async {
    try {
      final response = await _supabaseClient
          .from('workout_categories')
          .select()
          .order('order', ascending: true);
          
      return (response as List<dynamic>)
          .map((data) => WorkoutCategory.fromJson(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar categorias de treino do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar categorias de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .eq('type', category)
          .order('created_at', ascending: false);
          
      return (response as List<dynamic>)
          .map((data) => _mapToWorkout(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar treinos por categoria do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos por categoria',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> getWorkoutById(String id) async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .eq('id', id)
          .single();
          
      return _mapToWorkout(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado',
          code: 'workout_not_found',
        );
      }
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar treino do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<Workout> createWorkout(Workout workout) async {
    try {
      final workoutJson = workout.toJson();
      // Remover o ID se for criar um novo
      workoutJson.remove('id');
      
      final response = await _supabaseClient
          .from('workouts')
          .insert(workoutJson)
          .select()
          .single();
          
      return _mapToWorkout(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao criar treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar treino',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> updateWorkout(Workout workout) async {
    try {
      final workoutJson = workout.toJson();
      
      final response = await _supabaseClient
          .from('workouts')
          .update(workoutJson)
          .eq('id', workout.id)
          .select()
          .single();
          
      return _mapToWorkout(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado para atualização',
          code: 'workout_not_found',
        );
      }
      throw app_errors.DatabaseException(
        message: 'Erro ao atualizar treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao atualizar treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteWorkout(String id) async {
    try {
      await _supabaseClient.from('workouts').delete().eq('id', id);
    } catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao excluir treino',
        originalError: e,
      );
    }
  }

  // Métodos auxiliares para converter dados do Supabase
  Workout _mapToWorkout(Map<String, dynamic> data) {
    return Workout(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      imageUrl: data['image_url'] as String? ?? 'assets/images/workout_default.jpg',
      type: data['type'] as String,
      durationMinutes: data['duration_minutes'] as int,
      difficulty: data['difficulty'] as String,
      equipment: _parseList(data['equipment']),
      sections: _parseSections(data['sections']),
      creatorId: data['created_by'] as String? ?? '',
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
  
  List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is Map) {
      try {
        final list = value.values.toList();
        return list.map((e) => e.toString()).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }
  
  List<WorkoutSection> _parseSections(dynamic sectionsData) {
    if (sectionsData == null) return [];
    
    try {
      final sections = <WorkoutSection>[];
      final List<dynamic> sectionsList = sectionsData is String 
          ? jsonDecode(sectionsData) as List<dynamic>
          : sectionsData as List<dynamic>;
          
      for (final section in sectionsList) {
        final exercises = <Exercise>[];
        final exercisesData = section['exercises'] as List<dynamic>? ?? [];
        
        for (final exerciseData in exercisesData) {
          exercises.add(Exercise(
            name: exerciseData['name'] as String,
            description: exerciseData['description'] as String?,
            sets: exerciseData['sets'] as int? ?? 3,
            reps: exerciseData['reps'] as int? ?? 12,
            restSeconds: exerciseData['rest_seconds'] as int? ?? 60,
            imageUrl: exerciseData['image_url'] as String?,
            videoUrl: exerciseData['video_url'] as String?,
          ));
        }
        
        sections.add(WorkoutSection(
          name: section['name'] as String,
          exercises: exercises,
        ));
      }
      
      return sections;
    } catch (e) {
      print('Erro ao analisar seções: $e');
      return [];
    }
  }
}

// Provider para o repositório de workout
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabaseWorkoutRepository(client);
}); 
