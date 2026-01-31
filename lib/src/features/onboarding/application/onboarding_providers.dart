import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final DateTime? examDate;
  final int dailyGoal;

  const OnboardingState({
    this.examDate,
    this.dailyGoal = 50, // Default goal (Standard)
  });

  OnboardingState copyWith({DateTime? examDate, int? dailyGoal}) {
    return OnboardingState(
      examDate: examDate ?? this.examDate,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setExamDate(DateTime date) {
    state = state.copyWith(examDate: date);
  }

  void setDailyGoal(int goal) {
    state = state.copyWith(dailyGoal: goal);
  }
}

final onboardingStateProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier();
    });
