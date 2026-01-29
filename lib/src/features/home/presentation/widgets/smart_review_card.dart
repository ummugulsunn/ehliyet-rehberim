import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ehliyet_rehberim/src/core/theme/app_colors.dart';
// import 'package:ehliyet_rehberim/src/features/home/data/user_progress_repository.dart';
import 'package:ehliyet_rehberim/src/features/quiz/application/smart_quiz_provider.dart';
import 'package:ehliyet_rehberim/src/features/quiz/presentation/quiz_screen.dart';
import 'package:ehliyet_rehberim/src/features/quiz/application/quiz_providers.dart';
import 'package:ehliyet_rehberim/src/features/stats/application/stats_providers.dart';
// import 'package:ehliyet_rehberim/src/features/quiz/domain/question_model.dart'; // Add this import

class SmartReviewCard extends ConsumerWidget {
  const SmartReviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user progress to check if unlocked
    final testResultsAsync = ref.watch(testResultsProvider);

    return testResultsAsync.when(
      data: (results) {
        final isUnlocked = results.length >= 3;
        final weakCategories = ref.read(userProgressRepositoryProvider).getWeakestCategories(limit: 1);
        final weakCategory = weakCategories.isNotEmpty ? weakCategories.first : 'Genel';

        return Card(
          elevation: isUnlocked ? 4 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isUnlocked 
              ? Theme.of(context).colorScheme.primaryContainer 
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: isUnlocked ? () => _startSmartQuiz(context, ref) : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isUnlocked ? Icons.auto_awesome : Icons.lock_outline,
                      size: 28,
                      color: isUnlocked ? Theme.of(context).colorScheme.onPrimaryContainer : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Akıllı Tekrar',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked 
                                ? Theme.of(context).colorScheme.onPrimaryContainer 
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isUnlocked 
                              ? 'Zayıf Noktan: $weakCategory'
                              : 'Veri Toplanıyor (${results.length}/3 Test)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isUnlocked 
                                ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    Icon(
                      Icons.arrow_forward_ios, 
                      size: 16, 
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.5)
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _startSmartQuiz(BuildContext context, WidgetRef ref) async {
    // Show loading or similar if needed, but FutureProvider will be awaited in the provider itself or we await here
    // Ideally we transition to loading stats.
    
    // We can't await a provider easily here without a FutureProvider reading execution.
    // Let's manually trigger logic or use a helper. 
    // Actually, passing questions directly to QuizScreen is proper custom exam flow.
    
    // Show loading indicator dialog
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator())
    );

    try {
      final questions = await ref.read(smartQuizProvider.future);
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        
        if (questions.isNotEmpty) {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                examId: 'smart_review',
                category: 'Akıllı Tekrar',
                preloadedQuestions: questions,
              ),
            ),
          );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Yeterli soru bulunamadı.'))
           );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Hata oluştu: $e'))
        );
      }
    }
  }
}
