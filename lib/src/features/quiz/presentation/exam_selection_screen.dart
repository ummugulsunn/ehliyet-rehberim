import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/quiz_service.dart';
import '../application/quiz_providers.dart';
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
      body: FutureBuilder<List<Exam>>(
        future: quizRepository.loadExams(),
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
          final exams = snapshot.data!;
          if (exams.isEmpty) {
            return const Center(child: Text('Henüz deneme sınavı yok.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Messages list
                ...exams.map((exam) => _buildExamCard(exam, progressRepository, context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamCard(Exam exam, UserProgressRepository progressRepository, BuildContext context) {
    final results = progressRepository.getAllTestResults(examId: exam.examId);
    final best = results.isEmpty ? null : results.map((r) => r.correctAnswers).reduce((a, b) => a > b ? a : b);

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
              // Navigate to review screen with the most recent result
              results.sort((a, b) => b.date.compareTo(a.date));
              final last = results.first;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizReviewScreen(result: last, questions: exam.questions),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizScreen(examId: exam.examId),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
          child: Text(best != null ? 'İncele' : 'Başla'),
        ),
      ),
    );
  }


}

