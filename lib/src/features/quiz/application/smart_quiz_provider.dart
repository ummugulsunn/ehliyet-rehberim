import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../home/data/user_progress_repository.dart';
import '../../quiz/domain/question_model.dart';
import 'quiz_providers.dart';

/// Provider that generates a "Smart Review" exam based on user's weak topics
final smartQuizProvider = FutureProvider<List<Question>>((ref) async {
  final userProgressRepo = ref.read(userProgressRepositoryProvider);
  final quizRepo = ref.read(quizRepositoryProvider);

  // 1. Get Due Mistakes (SRS) - High Priority
  final dueMistakes = await ref.read(wrongQuestionsProvider.future);
  
  List<Question> smartExam = List.from(dueMistakes);
  
  // If we have enough mistakes (e.g. 20+), just return them (shuffled)
  if (smartExam.length >= 20) {
    smartExam.shuffle();
    return smartExam.take(20).toList();
  }

  // 2. Fill with Weak Categories
  // If we need more questions, find weak topics
  final remainingCount = 20 - smartExam.length;
  final weakCategories = userProgressRepo.getWeakestCategories(limit: 3);
  
  final allQuestions = await quizRepo.loadQuestionsForExam('karma');
  final random = Random();

  if (weakCategories.isNotEmpty) {
     for (final category in weakCategories) {
        if (smartExam.length >= 20) break;
        
        final categoryQuestions = allQuestions
            .where((q) => q.category == category && !smartExam.any((e) => e.id == q.id))
            .toList();
            
        categoryQuestions.shuffle(random);
        // Add a few from each category
        smartExam.addAll(categoryQuestions.take(5));
     }
  }

  // 3. Fill with Randoms if still needed
  if (smartExam.length < 20) {
    final needed = 20 - smartExam.length;
    final otherQuestions = allQuestions
        .where((q) => !smartExam.any((e) => e.id == q.id))
        .toList();
    otherQuestions.shuffle(random);
    smartExam.addAll(otherQuestions.take(needed));
  }
  
  smartExam.shuffle(random);
  return smartExam;
});
