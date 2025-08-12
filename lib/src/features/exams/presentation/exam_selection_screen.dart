import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/quiz_service.dart';
import '../../quiz/application/quiz_providers.dart';
// ignore: unused_import
import '../../../core/services/quiz_service.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/services/user_progress_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../../quiz/presentation/quiz_review_screen.dart';
import '../../paywall/presentation/paywall_screen.dart';

class ExamSelectionScreen extends ConsumerWidget {
  const ExamSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizService = ref.read(quizServiceProvider);
    final progressService = UserProgressService.instance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Deneme Sınavları', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: FutureBuilder<List<Exam>>(
        future: quizService.loadExams(),
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
                // Free Exams (First 10)
                ...exams.take(10).map((exam) => _buildExamCard(exam, progressService, context)),
                
                // Pro Upgrade Banner
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.premium, AppColors.premiumLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.premiumShadow.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.onPremium.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: AppColors.onPremium,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pro Sürüme Geç',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onPremium,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '1000+ fazla soruya erişim kazanın',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onPremium.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PaywallScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.onPremium,
                            foregroundColor: AppColors.premium,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Pro\'ya Geç',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Pro Exams (Last 5 - Locked)
                ...exams.skip(10).take(5).map((exam) => _buildProExamCard(exam, context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamCard(Exam exam, UserProgressService progressService, BuildContext context) {
    final results = progressService.getAllTestResults(examId: exam.examId);
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
            final results = progressService.getAllTestResults(examId: exam.examId);
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

  Widget _buildProExamCard(Exam exam, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.premium.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.lock,
            color: AppColors.premium,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                exam.examName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.premium, AppColors.premiumLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'PRO',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onPremium,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Pro sürüme geçerek 1000+ fazla soruya erişin',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PaywallScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.premium,
            foregroundColor: AppColors.onPremium,
          ),
          child: const Text('Pro\'ya Geç'),
        ),
      ),
    );
  }
}

