import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../application/favorites_providers.dart';
import '../../quiz/presentation/quiz_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesListProvider);
    final favoritedQuestionsAsync = ref.watch(favoritedQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz favori soru eklemediniz.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return favoritedQuestionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Sorular yüklenemedi: $err')),
            data: (questions) {
              if (questions.isEmpty) {
                return const Center(child: Text('Favori sorular yüklenirken hata oluştu.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  // Sort by newest first
                  final reversedIndex = favorites.length - 1 - index;
                  final favItem = favorites[reversedIndex];
                  
                  // Find corresponding question
                  final question = questions.firstWhere(
                    (q) => q.id == favItem.questionId,
                    orElse: () => questions.first, // Fallback, shouldn't happen usually
                  );
                  
                  // If question not found (maybe data mismatch), skip or show placeholder
                  if (question.id != favItem.questionId) {
                    return const SizedBox.shrink(); 
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        question.questionText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          if (favItem.note != null && favItem.note!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.sticky_note_2, size: 16, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      favItem.note!,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Kategori: ${question.category}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () {
                          ref.read(favoritesRepositoryProvider).toggleFavorite(favItem.questionId);
                        },
                      ),
                      onTap: () {
                        // Show edit note dialog
                        // Reusing a simplified version of the logic from QuizScreen
                         final noteController = TextEditingController(text: favItem.note);
                         showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Not Düzenle'),
                            content: TextField(
                              controller: noteController,
                              decoration: const InputDecoration(
                                hintText: 'Notunuz...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('İptal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(favoritesRepositoryProvider).saveNote(favItem.questionId, noteController.text);
                                  Navigator.pop(context);
                                },
                                child: const Text('Kaydet'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: favoritesAsync.asData?.value.isNotEmpty == true
          ? FloatingActionButton.extended(
              onPressed: () {
                favoritedQuestionsAsync.whenData((questions) {
                  if (questions.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          examId: 'favorites_quiz',
                          category: 'Favorilerim',
                          preloadedQuestions: questions,
                        ),
                      ),
                    );
                  }
                });
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Tümünü Çöz'),
            )
          : null,
    );
  }
}
