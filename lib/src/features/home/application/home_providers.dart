import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/user_progress_repository.dart';

/// Provider for the UserProgressRepository singleton instance
final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  return UserProgressRepository.instance;
});

/// StreamProvider that watches the daily progress stream
/// Returns the number of questions answered today
final dailyProgressProvider = StreamProvider<int>((ref) {
  final userProgressRepository = ref.read(userProgressRepositoryProvider);
  return userProgressRepository.dailyProgressStream;
});

/// StreamProvider that watches the unified user progress state
final userProgressStateProvider = StreamProvider<UserProgressState>((ref) {
  final userProgressRepository = ref.read(userProgressRepositoryProvider);
  return userProgressRepository.stateStream;
});

/// StreamProvider that watches the streak stream
/// Returns the current streak count
final streakProvider = StreamProvider<int>((ref) {
  final userProgressRepository = ref.read(userProgressRepositoryProvider);
  return userProgressRepository.streakStream;
});

/// Provider that returns the daily goal (constant value)
final dailyGoalProvider = Provider<int>((ref) {
  return 50; // Daily goal of 50 questions
});

/// Provider that returns the progress percentage for today
final dailyProgressPercentageProvider = Provider<double>((ref) {
  final dailyProgressAsync = ref.watch(dailyProgressProvider);
  final dailyGoal = ref.watch(dailyGoalProvider);
  
  return dailyProgressAsync.when(
    data: (progress) => progress / dailyGoal,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Provider that returns whether the daily goal is completed
final isDailyGoalCompletedProvider = Provider<bool>((ref) {
  final dailyProgressAsync = ref.watch(dailyProgressProvider);
  final dailyGoal = ref.watch(dailyGoalProvider);
  
  return dailyProgressAsync.when(
    data: (progress) => progress >= dailyGoal,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider that returns the formatted streak text
final streakTextProvider = Provider<String>((ref) {
  final streakAsync = ref.watch(streakProvider);
  
  return streakAsync.when(
    data: (streak) {
      if (streak == 0) return '';
      if (streak == 1) return '1 Günlük Seri!';
      return '$streak Günlük Seri!';
    },
    loading: () => '',
    error: (_, __) => '',
  );
});

/// StreamProvider that watches the XP stream
final xpProvider = StreamProvider<int>((ref) {
  final userProgressRepository = ref.read(userProgressRepositoryProvider);
  return userProgressRepository.xpStream;
});

/// StreamProvider that watches the level stream
final levelProvider = StreamProvider<int>((ref) {
  final userProgressRepository = ref.read(userProgressRepositoryProvider);
  return userProgressRepository.levelStream;
});

/// Provider for Level Title (Rank)
final levelTitleProvider = Provider<String>((ref) {
  final levelAsync = ref.watch(levelProvider);
  
  return levelAsync.when(
    data: (level) {
      if (level < 5) return 'Acemi Sürücü';
      if (level < 10) return 'Şehir İçi Uzmanı';
      if (level < 20) return 'Otoyol Faresi';
      if (level < 50) return 'Trafik Efsanesi';
      return 'Ehliyet Kralı';
    },
    loading: () => 'Acemi Sürücü',
    error: (_, __) => 'Acemi Sürücü',
  );
});

/// StreamProvider that watches the unlocked achievements stream
final achievementsProvider = StreamProvider<List<String>>((ref) {
  final userProgressRepository = ref.read(userProgressRepositoryProvider);
  return userProgressRepository.achievementsStream;
});