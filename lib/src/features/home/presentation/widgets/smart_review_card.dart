import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
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
    final resultsAsync = ref.watch(testResultsProvider);
    final mistakesAsync = ref.watch(wrongQuestionsProvider); // Watch mistakes

    return resultsAsync.when(
      data: (results) {
        // Unlock if at least 1 exam is finished
        final isUnlocked = results.isNotEmpty;
        
        // Determine what to show
        String statusText = 'Veri Toplanıyor (En az 1 sınav çözün)';
        bool hasMistakes = false;
        int mistakeCount = 0;

        if (isUnlocked) {
           mistakeCount = mistakesAsync.valueOrNull?.length ?? 0;
           if (mistakeCount > 0) {
             statusText = 'Tekrar Edilecek: $mistakeCount Hata';
             hasMistakes = true;
           } else {
             final weakCategories = ref.read(userProgressRepositoryProvider).getWeakestCategories(limit: 1);
             final weakCategory = weakCategories.isNotEmpty ? weakCategories.first : 'Genel';
             statusText = 'Zayıf Noktanız: $weakCategory';
           }
        }

        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked 
                  ? (hasMistakes ? AppColors.error.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.3))
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: isUnlocked ? [
              BoxShadow(
                color: (hasMistakes ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : [],
          ),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isUnlocked 
                ? (hasMistakes ? colorScheme.errorContainer.withValues(alpha: 0.3) : colorScheme.primaryContainer) 
                : colorScheme.surfaceContainerHighest,
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
                        color: isUnlocked 
                            ? (hasMistakes ? AppColors.error.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15))
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUnlocked 
                              ? (hasMistakes ? AppColors.error.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3))
                              : Colors.grey.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isUnlocked ? Icons.auto_awesome : Icons.lock_outline,
                        size: 28,
                        color: isUnlocked 
                            ? (hasMistakes ? AppColors.error : AppColors.primary)
                            : Colors.grey,
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
                                  ? (hasMistakes ? AppColors.error : colorScheme.onPrimaryContainer) 
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isUnlocked 
                                  ? (hasMistakes ? AppColors.error.withValues(alpha: 0.8) : colorScheme.onPrimaryContainer.withValues(alpha: 0.8))
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnlocked)
                      Icon(
                        Icons.arrow_forward_ios, 
                        size: 16, 
                        color: (hasMistakes ? AppColors.error : AppColors.primary).withValues(alpha: 0.6)
                      ),
                  ],
                ),
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
