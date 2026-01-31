import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/quiz_service.dart';
import '../application/quiz_providers.dart';
import '../data/exam_storage_service.dart';
// ignore: unused_import
import '../data/quiz_repository.dart';
import '../domain/exam_model.dart';
import '../../home/data/user_progress_repository.dart';
import '../../../core/theme/app_colors.dart';
import 'quiz_screen.dart';
import 'quiz_review_screen.dart';


class ExamSelectionScreen extends ConsumerWidget {
  const ExamSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizRepository = ref.read(quizRepositoryProvider);
    final progressRepository = UserProgressRepository.instance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Deneme Sınavları', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          quizRepository.loadExams(),
          ref.read(examStorageServiceProvider).getAllUnfinishedExamIds(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Sınavlar yüklenemedi', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(snapshot.error.toString(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Sınav verisi bulunamadı'));
          }
          
          final exams = snapshot.data![0] as List<Exam>;
          final unfinishedIds = snapshot.data![1] as Set<String>;
          
          if (exams.isEmpty) {
            return const Center(child: Text('Henüz deneme sınavı yok.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Messages list
                ...exams.map((exam) => _buildExamCard(exam, progressRepository, context, ref, unfinishedIds)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamCard(Exam exam, UserProgressRepository progressRepository, BuildContext context, WidgetRef ref, Set<String> unfinishedIds) {
    final results = progressRepository.getAllTestResults(examId: exam.examId);
    final best = results.isEmpty ? null : results.map((r) => r.correctAnswers).reduce((a, b) => a > b ? a : b);
    final hasUnfinished = unfinishedIds.contains(exam.examId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(exam.examName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: best != null
            ? Text('En Yüksek: $best/${exam.questions.length}', style: Theme.of(context).textTheme.bodyMedium)
            : Text('Hazır mısın? Hemen başla!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: ElevatedButton(
          onPressed: () async {
            if (!context.mounted) return;
            // Check if there is a saved result for this exam
            final results = progressRepository.getAllTestResults(examId: exam.examId);
            
            if (results.isNotEmpty) {
              // Get the most recent result
              results.sort((a, b) => b.date.compareTo(a.date));
              final lastResult = results.first;

              // Ask user: Review or Restart?
              final choice = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sınav Durumu'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bu sınavı daha önce çözdünüz.'),
                      const SizedBox(height: 8),
                      Text('Son Sonuç: ${lastResult.correctAnswers}/${lastResult.totalQuestions} Doğru'),
                      const SizedBox(height: 16),
                      const Text('Ne yapmak istersiniz?'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'review'),
                      child: const Text('Sonucu İncele'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, 'restart'),
                      child: const Text('Yeniden Başla'),
                    ),
                  ],
                ),
              );

              if (choice == 'review' && context.mounted) {
                 Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizReviewScreen(result: lastResult, questions: exam.questions),
                  ),
                );
              } else if (choice == 'restart' && context.mounted) {
                // Reset quiz state to ensure a fresh start
                ref.read(quizControllerProvider(exam.examId).notifier).reset();
                
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(examId: exam.examId),
                  ),
                );
              }
            } else {
              // No previous result, start directly
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizScreen(examId: exam.examId),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: hasUnfinished ? AppColors.warning : AppColors.primary, 
            foregroundColor: AppColors.onPrimary
          ),
          child: Text(
            hasUnfinished ? 'Devam Et' : (best != null ? 'Tekrarla / İncele' : 'Başla')
          ),
        ),
      ),
    );
  }


}

