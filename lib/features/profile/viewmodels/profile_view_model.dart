// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/supabase_providers.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';
import '../repositories/supabase_profile_repository.dart';
import 'profile_state.dart';

/// Provider para o repositório de perfil
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // Em ambiente de produção, usa a implementação Supabase
  // Em desenvolvimento ou testes, pode usar o mock
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(supabase);
  
  // Versão mock para desenvolvimento
  // return MockProfileRepository();
});

/// Provider para o ViewModel de perfil
final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(ref.watch(profileRepositoryProvider));
});

/// ViewModel para gerenciar o perfil do usuário
class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  
  /// Construtor
  ProfileViewModel(this._repository) : super(const ProfileState.initial());
  
  /// Carrega o perfil do usuário atual
  Future<void> loadCurrentUserProfile() async {
    try {
      state = const ProfileState.loading();
      
      final profile = await _repository.getCurrentUserProfile();
      
      if (profile != null) {
        state = ProfileState.loaded(profile: profile);
      } else {
        state = const ProfileState.error('Perfil não encontrado');
      }
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = ProfileState.error(errorMessage);
    }
  }
  
  /// Carrega o perfil do usuário por ID
  Future<void> loadProfileById(String userId) async {
    try {
      state = const ProfileState.loading();
      
      final profile = await _repository.getProfileById(userId);
      
      if (profile != null) {
        state = ProfileState.loaded(profile: profile);
      } else {
        state = const ProfileState.error('Perfil não encontrado');
      }
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = ProfileState.error(errorMessage);
    }
  }
  
  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    String? name,
    String? bio,
    List<String>? goals,
    String? phone,
    String? gender,
    DateTime? birthDate,
    String? instagram,
  }) async {
    try {
      final currentProfile = state.profile;
      if (currentProfile == null) {
        state = const ProfileState.error('Perfil não disponível para atualização');
        return;
      }
      
      state = ProfileState.updating(profile: currentProfile);
      
      final updatedProfile = await _repository.updateProfile(
        currentProfile.copyWith(
          name: name ?? currentProfile.name,
          bio: bio ?? currentProfile.bio,
          goals: goals ?? currentProfile.goals,
          phone: phone ?? currentProfile.phone,
          gender: gender ?? currentProfile.gender,
          birthDate: birthDate ?? currentProfile.birthDate,
          instagram: instagram ?? currentProfile.instagram,
        ),
      );
      
      state = ProfileState.loaded(profile: updatedProfile);
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = ProfileState.error(errorMessage);
    }
  }
  
  /// Atualiza o email do usuário
  Future<void> updateEmail(String email) async {
    try {
      final currentProfile = state.profile;
      if (currentProfile == null) {
        state = const ProfileState.error('Perfil não disponível para atualização');
        return;
      }
      
      state = ProfileState.updating(profile: currentProfile);
      
      await _repository.updateEmail(currentProfile.id, email);
      
      final updatedProfile = currentProfile.copyWith(
        email: email,
        updatedAt: DateTime.now(),
      );
      
      state = ProfileState.loaded(profile: updatedProfile);
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = ProfileState.error(errorMessage);
    }
  }
  
  /// Envia link para redefinição de senha
  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _repository.sendPasswordResetLink(email);
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      throw Exception(errorMessage);
    }
  }
  
  /// Atualiza a foto de perfil do usuário
  Future<void> updateProfilePhoto(String filePath) async {
    try {
      final currentProfile = state.profile;
      if (currentProfile == null) {
        state = const ProfileState.error('Perfil não disponível para atualização');
        return;
      }
      
      state = ProfileState.updating(profile: currentProfile);
      
      final photoUrl = await _repository.updateProfilePhoto(
        currentProfile.id,
        filePath,
      );
      
      final updatedProfile = currentProfile.copyWith(photoUrl: photoUrl);
      
      state = ProfileState.loaded(profile: updatedProfile);
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = ProfileState.error(errorMessage);
    }
  }
  
  /// Adiciona um treino aos favoritos
  Future<void> addWorkoutToFavorites(String workoutId) async {
    try {
      final currentProfile = state.profile;
      if (currentProfile == null) {
        state = const ProfileState.error('Perfil não disponível para atualização');
        return;
      }
      
      // Verifica se o treino já está nos favoritos
      if (currentProfile.favoriteWorkoutIds.contains(workoutId)) {
        return; // Já está nos favoritos, não faz nada
      }
      
      state = ProfileState.updating(profile: currentProfile);
      
      final updatedProfile = await _repository.addWorkoutToFavorites(
        currentProfile.id,
        workoutId,
      );
      
      state = ProfileState.loaded(profile: updatedProfile);
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = ProfileState.error(errorMessage);
    }
  }
  
  /// Remove um treino dos favoritos
  Future<void> removeWorkoutFromFavorites(String workoutId) async {
    try {
      final currentProfile = state.profile;
      if (currentProfile == null) {
        state = const ProfileState.error('Perfil não disponível para atualização');
        return;
      }
      
      // Verifica se o treino está nos favoritos
      if (!currentProfile.favoriteWorkoutIds.contains(workoutId)) {
        return; // Não está nos favoritos, não faz nada
      }
      
      state = ProfileState.updating(profile: currentProfile);
      
      final updatedProfile = await _repository.removeWorkoutFromFavorites(
        currentProfile.id,
        workoutId,
      );
      
      state = ProfileState.loaded(profile: updatedProfile);
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = ProfileState.error(errorMessage);
    }
  }
  
  /// Registra um treino como completado e adiciona pontos
  Future<void> completeWorkout({int pointsEarned = 10}) async {
    try {
      final currentProfile = state.profile;
      if (currentProfile == null) {
        state = const ProfileState.error('Perfil não disponível para atualização');
        return;
      }
      
      state = ProfileState.updating(profile: currentProfile);
      
      // Incrementa o contador de treinos
      var updatedProfile = await _repository.incrementCompletedWorkouts(
        currentProfile.id,
      );
      
      // Adiciona pontos pelo treino completado
      if (pointsEarned > 0) {
        updatedProfile = await _repository.addPoints(
          currentProfile.id,
          pointsEarned,
        );
      }
      
      // Verifica e atualiza streak se necessário (lógica simplificada)
      final newStreak = updatedProfile.streak + 1;
      updatedProfile = await _repository.updateStreak(
        currentProfile.id,
        newStreak,
      );
      
      state = ProfileState.loaded(profile: updatedProfile);
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = ProfileState.error(errorMessage);
    }
  }
  
  /// Adiciona pontos ao usuário
  Future<void> addPoints(int points) async {
    try {
      final currentProfile = state.profile;
      if (currentProfile == null) {
        state = const ProfileState.error('Perfil não disponível para atualização');
        return;
      }
      
      state = ProfileState.updating(profile: currentProfile);
      
      final updatedProfile = await _repository.addPoints(
        currentProfile.id,
        points,
      );
      
      state = ProfileState.loaded(profile: updatedProfile);
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = ProfileState.error(errorMessage);
    }
  }
  
  /// Limpa mensagem de erro
  void clearError() {
    final currentProfile = state.profile;
    if (currentProfile != null) {
      state = ProfileState.loaded(profile: currentProfile);
    } else {
      state = const ProfileState.initial();
    }
  }
  
  /// Trata erros de maneira unificada e retorna uma mensagem adequada para o usuário
  String _handleError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Error in ProfileViewModel: $error');
      print(stackTrace);
    }
    
    if (error is AppException) {
      return error.message;
    }
    
    return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
  }
} 
