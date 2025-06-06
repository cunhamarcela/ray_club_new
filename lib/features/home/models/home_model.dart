// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_model.freezed.dart';
part 'home_model.g.dart';

/// Modelo para a tela Home, representando os dados que a tela precisa exibir
@freezed
class HomeData with _$HomeData {
  const factory HomeData({
    /// Banner atual em destaque
    required BannerItem activeBanner,
    
    /// Lista de banners disponíveis para rotação
    required List<BannerItem> banners,
    
    /// Indicadores de progresso do usuário
    required UserProgress progress,
    
    /// Categorias de treino disponíveis
    required List<WorkoutCategory> categories,
    
    /// Treinos populares para exibição
    required List<PopularWorkout> popularWorkouts,
    
    /// Data da última atualização
    required DateTime lastUpdated,
  }) = _HomeData;

  /// Conversor de JSON para HomeData
  factory HomeData.fromJson(Map<String, dynamic> json) => _$HomeDataFromJson(json);
  
  /// Cria uma instância vazia para inicialização
  factory HomeData.empty() => HomeData(
    activeBanner: BannerItem.empty(),
    banners: [],
    progress: UserProgress.empty(),
    categories: [],
    popularWorkouts: [],
    lastUpdated: DateTime.now(),
  );
}

/// Modelo para banners promocionais
@freezed
class BannerItem with _$BannerItem {
  const factory BannerItem({
    required String id,
    required String title,
    required String subtitle,
    required String imageUrl,
    String? actionUrl,
    @Default(false) bool isActive,
  }) = _BannerItem;

  /// Conversor de JSON para BannerItem
  factory BannerItem.fromJson(Map<String, dynamic> json) => _$BannerItemFromJson(json);
  
  /// Cria uma instância vazia para inicialização
  factory BannerItem.empty() => const BannerItem(
    id: '',
    title: '',
    subtitle: '',
    imageUrl: '',
  );
}

/// Modelo para progresso do usuário
@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    /// Número de dias treinados no mês
    @Default(0) int daysTrainedThisMonth,
    
    /// Sequência atual de dias treinados
    @Default(0) int currentStreak,
    
    /// Melhor sequência histórica
    @Default(0) int bestStreak,
    
    /// Porcentagem de progresso no desafio atual (0-100)
    @Default(0) int challengeProgress,
  }) = _UserProgress;

  /// Conversor de JSON para UserProgress
  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);
  
  /// Cria uma instância vazia para inicialização
  factory UserProgress.empty() => const UserProgress();
}

/// Modelo para categorias de treino
@freezed
class WorkoutCategory with _$WorkoutCategory {
  const factory WorkoutCategory({
    required String id,
    required String name,
    required String iconUrl,
    required int workoutCount,
    String? colorHex,
  }) = _WorkoutCategory;

  /// Conversor de JSON para WorkoutCategory
  factory WorkoutCategory.fromJson(Map<String, dynamic> json) => _$WorkoutCategoryFromJson(json);
}

/// Modelo para treinos populares
@freezed
class PopularWorkout with _$PopularWorkout {
  const factory PopularWorkout({
    required String id,
    required String title,
    required String imageUrl,
    required String duration,
    required String difficulty,
    @Default(0) int favoriteCount,
  }) = _PopularWorkout;

  /// Conversor de JSON para PopularWorkout
  factory PopularWorkout.fromJson(Map<String, dynamic> json) => _$PopularWorkoutFromJson(json);
} 
