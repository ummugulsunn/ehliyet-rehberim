import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/user_progress_service.dart';

/// Provider for the UserProgressService singleton instance
final userProgressServiceProvider = Provider<UserProgressService>((ref) {
  return UserProgressService.instance;
});

/// StreamProvider that watches the daily progress stream
/// Returns the number of questions answered today
final dailyProgressProvider = StreamProvider<int>((ref) {
  final userProgressService = ref.read(userProgressServiceProvider);
  return userProgressService.dailyProgressStream;
});

/// StreamProvider that watches the streak stream
/// Returns the current streak count
final streakProvider = StreamProvider<int>((ref) {
  final userProgressService = ref.read(userProgressServiceProvider);
  return userProgressService.streakStream;
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