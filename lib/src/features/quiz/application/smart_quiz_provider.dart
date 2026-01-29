import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../home/data/user_progress_repository.dart';
import '../../quiz/domain/question_model.dart';
import 'quiz_providers.dart';

/// Provider that generates a "Smart Review" exam based on user's weak topics
final smartQuizProvider = FutureProvider<List<Question>>((ref) async {
  final userProgressRepo = ref.read(userProgressRepositoryProvider);
  final quizRepo = ref.read(quizRepositoryProvider);

  // 1. Identify Weakest Categories
  // Get all test results first to check if we have enough data
  final allResults = userProgressRepo.getAllTestResults();
  if (allResults.length < 3) {
    // Not enough data yet
    return [];
  }

  // Get bottom 2 categories
  final weakCategories = userProgressRepo.getWeakestCategories(limit: 2);
  
  // If no specific stats (e.g. only solved general exams), fallback to random mix
  if (weakCategories.isEmpty) {
     final allQuestions = await quizRepo.loadQuestionsForExam('karma');
     return allQuestions.take(20).toList(); // Simple fallback
  }

  // 2. Load Questions for Weak Categories
  // We need to load questions from ALL exams to filter by category
  // Assuming 'karma' loads everything or we iterate available exams.
  // Ideally, QuizRepository should have a `getQuestionsByCategory` method. 
  // For now, we reuse `loadQuestionsForExam('karma')` which conceptually merges sources or load from JSONs.
  
  // Since we consolidated exams, we likely have a way to get all.
  final allQuestions = await quizRepo.loadQuestionsForExam('karma');
  
  final List<Question> smartExam = [];
  final random = Random();

  for (final category in weakCategories) {
    final categoryQuestions = allQuestions.where((q) => q.category == category).toList();
    // Shuffle and pick 10
    categoryQuestions.shuffle(random);
    smartExam.addAll(categoryQuestions.take(10));
  }

  // If we still need more questions (e.g. only 1 weak category found), fill with randoms
  if (smartExam.length < 20) {
    final remainingCount = 20 - smartExam.length;
    final otherQuestions = allQuestions.where((q) => !weakCategories.contains(q.category)).toList();
    otherQuestions.shuffle(random);
    smartExam.addAll(otherQuestions.take(remainingCount));
  }
  
  // Shuffle final exam
  smartExam.shuffle(random);
  
  return smartExam;
});
