import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/quiz_providers.dart';
import '../../../core/theme/app_colors.dart';

import '../domain/test_result_model.dart';


class ResultsScreen extends ConsumerWidget {
  final String examId;
  final TestResult? result;

  const ResultsScreen({
    super.key,
    required this.examId,
    this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider(examId));
    final isExamMode = quizState.isExamMode;
    
    // Calculate statistics
    // Calculate statistics
    final totalQuestions = result?.totalQuestions ?? quizState.totalQuestions;
    final correctAnswers = result?.correctAnswers ?? quizState.score;
    final incorrectAnswers = totalQuestions - correctAnswers;
    // For result object, we calculate success percentage directly
    final successPercentage = result != null 
        ? (totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0)
        : (totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0);
        
    final isPassed = successPercentage >= 70;
    
    // Time taken: use result if available, otherwise provider
    final timeTakenDuration = result?.timeTakenInSeconds != null 
        ? Duration(seconds: result!.timeTakenInSeconds!)
        : ref.read(quizControllerProvider(examId).notifier).getTimeTaken();


    return Scaffold(
      appBar: AppBar(
        title: Text(isExamMode ? 'Sınav Sonuçları' : 'Test Sonuçları'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Congratulatory/Pass-Fail message
                    const SizedBox(height: 32),
                    if (isExamMode) ...[
                      Icon(
                        isPassed ? Icons.check_circle : Icons.cancel,
                        size: 80,
                        color: isPassed ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isPassed ? 'TEBRİKLER!\nSINAVI GEÇTİNİZ' : 'MAALESEF\nSINAVDAN KALDINIZ',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPassed ? AppColors.success : AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Icon(
                        Icons.celebration,
                        size: 80,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Test Tamamlandı!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Circular progress indicator with score
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: CircularProgressIndicator(
                              value: successPercentage / 100,
                              strokeWidth: 12,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getScoreColor(successPercentage),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$correctAnswers/$totalQuestions',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(successPercentage),
                                ),
                              ),
                              Text(
                                '%$successPercentage',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Results summary
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildResultRow(
                            context,
                            'Doğru Sayısı',
                            correctAnswers.toString(),
                            Icons.check_circle,
                            AppColors.success,
                          ),
                          const SizedBox(height: 16),
                          _buildResultRow(
                            context,
                            'Yanlış Sayısı',
                            incorrectAnswers.toString(),
                            Icons.cancel,
                            AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          if (isExamMode) ...[
                            _buildResultRow(
                              context,
                              'Süre',
                              timeTakenDuration != null 
                                ? '${timeTakenDuration.inMinutes}:${(timeTakenDuration.inSeconds % 60).toString().padLeft(2, '0')}'
                                : '--:--',
                              Icons.timer,
                              AppColors.info,
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildResultRow(
                            context,
                            'Başarı Yüzdesi',
                            '%$successPercentage',
                            Icons.percent,
                            _getScoreColor(successPercentage),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 32),

                    // Action buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final notifier = ref.read(quizControllerProvider(examId).notifier);
                              notifier.reset();
                              if (isExamMode) {
                                // For exam mode, we might want to reload questions or just restart
                                // Current implementation: reset and pop should return to HomeScreen 
                                // but if we want to restart the exam immediately, we need a way.
                                // For now, let's pop.
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Yeniden Başla',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              ref.read(quizControllerProvider(examId).notifier).reset();
                              if (context.mounted) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Ana Menüye Dön',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 70) {
      return AppColors.success;
    } else if (percentage >= 50) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
} 