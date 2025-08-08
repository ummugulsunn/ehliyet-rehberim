import 'package:flutter/material.dart';
import 'package:ehliyet_rehberim/src/core/models/test_result_model.dart';
import 'package:ehliyet_rehberim/src/core/models/question_model.dart';
import 'package:ehliyet_rehberim/src/core/theme/app_colors.dart';

class QuizReviewScreen extends StatelessWidget {
  final TestResult result;
  final List<Question> questions;

  const QuizReviewScreen({super.key, required this.result, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cevap İncelemesi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: PageView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final selected = result.selectedAnswers?[question.id];
          final isCorrect = selected != null && selected == question.correctAnswerKey;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: AppColors.shadow.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Soru ${index + 1} / ${questions.length}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? AppColors.success : AppColors.error, size: 18),
                            const SizedBox(width: 6),
                            Text(isCorrect ? 'Doğru' : 'Yanlış',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: isCorrect ? AppColors.success : AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (question.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(question.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(question.questionText, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  ...question.options.entries.map((entry) {
                    final key = entry.key;
                    final text = entry.value;
                    final bool isCorrectAnswer = key == question.correctAnswerKey;
                    final bool isUserSelected = key == selected;

                    Color containerColor = AppColors.surface;
                    Color borderColor = AppColors.outline.withValues(alpha: 0.3);
                    if (isCorrectAnswer) {
                      containerColor = AppColors.successContainer;
                      borderColor = AppColors.success;
                    } else if (isUserSelected && !isCorrectAnswer) {
                      containerColor = AppColors.errorContainer;
                      borderColor = AppColors.error;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: isCorrectAnswer ? AppColors.success : (isUserSelected ? AppColors.error : AppColors.surfaceContainerHighest), shape: BoxShape.circle),
                            child: Center(
                              child: Text(key, style: TextStyle(color: isCorrectAnswer || isUserSelected ? Colors.white : AppColors.onSurface, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary))),
                          if (isCorrectAnswer)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 6.0),
                              child: Icon(Icons.check_circle, color: AppColors.success),
                            )
                          else if (isUserSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 6.0),
                              child: Icon(Icons.cancel, color: AppColors.error),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Açıklama: ${question.explanation.isNotEmpty ? question.explanation : 'Bu soru için açıklama mevcut değil.'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

