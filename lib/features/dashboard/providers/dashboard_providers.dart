// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit.dart';

/// Provider para acesso direto aos dados do dashboard
final dashboardDataProvider = Provider<AsyncValue<DashboardData>>((ref) {
  return ref.watch(dashboardViewModelProvider);
});

/// Provider para acesso ao progresso do usuário
final userProgressProvider = Provider<AsyncValue<UserProgress>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.userProgress),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso ao consumo de água
final waterIntakeProvider = Provider<AsyncValue<Map<String, dynamic>?>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.additionalData['water_intake'] as Map<String, dynamic>?),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso às metas do usuário
final userGoalsProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) {
      final goals = data.additionalData['goals'] as List<dynamic>?;
      return AsyncValue.data(
        goals?.map((e) => e as Map<String, dynamic>).toList() ?? [],
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso aos treinos recentes
final recentWorkoutsProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) {
      final workouts = data.additionalData['recent_workouts'] as List<dynamic>?;
      return AsyncValue.data(
        workouts?.map((e) => e as Map<String, dynamic>).toList() ?? [],
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso ao desafio atual do usuário
final currentChallengeProvider = Provider<AsyncValue<Challenge?>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.currentChallenge),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso ao progresso do desafio atual
final challengeProgressProvider = Provider<AsyncValue<ChallengeProgress?>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.challengeProgress),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso aos benefícios resgatados pelo usuário
final redeemedBenefitsProvider = Provider<AsyncValue<List<RedeemedBenefit>>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.redeemedBenefits),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
}); 