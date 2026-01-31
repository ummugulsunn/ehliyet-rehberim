import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/favorites_repository.dart';
import '../domain/favorite_item_model.dart';
import '../../quiz/application/quiz_providers.dart';
import '../../quiz/domain/question_model.dart';

/// Provider for the FavoritesRepository singleton
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository.instance;
});

/// Future provider that initializes the repository and allows waiting for it
final favoritesInitializationProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  await repository.initialize();
});

/// Stream provider for the list of favorites
final favoritesListProvider = StreamProvider<List<FavoriteItem>>((ref) async* {
  // Ensure initialization happens
  await ref.watch(favoritesInitializationProvider.future);
  final repository = ref.watch(favoritesRepositoryProvider);

  // Yield current cached value immediately to avoid missing the initial stream event
  yield repository.getFavorites();

  // Then listen to future updates
  yield* repository.favoritesStream;
});

/// Provider to check if a specific question is favorited
final isFavoriteProvider = Provider.family<bool, int>((ref, questionId) {
  final favoritesAsync = ref.watch(favoritesListProvider);

  return favoritesAsync.when(
    data: (favorites) => favorites.any((item) => item.questionId == questionId),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider to get the note for a specific question
final questionNoteProvider = Provider.family<String?, int>((ref, questionId) {
  final favoritesAsync = ref.watch(favoritesListProvider);

  return favoritesAsync.when(
    data: (favorites) {
      try {
        final item = favorites.firstWhere(
          (item) => item.questionId == questionId,
        );
        return item.note;
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider that returns the full Question objects for favorited items
/// Aggregates questions from all exams
final favoritedQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final favorites = await ref.watch(favoritesListProvider.future);
  if (favorites.isEmpty) return [];

  final quizRepo = ref.read(quizRepositoryProvider);
  // Using 'karma' or 'exam_simulation' to get ALL questions
  // 'exam_simulation' is better as it handles shuffling but 'karma' gets all without limit
  // Wait, loadQuestionsForExam('karma') returns ALL questions now?
  // Let's verify QuizRepository behavior.
  // Yes, 'karma' loads everything.
  final allQuestions = await quizRepo.loadQuestionsForExam('karma');

  final favoritedIds = favorites.map((e) => e.questionId).toSet();

  return allQuestions.where((q) => favoritedIds.contains(q.id)).toList();
});
