import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/quiz_providers.dart';
import '../../../core/models/question_model.dart';
import 'results_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/test_result_model.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String examId;
  final String? category;
  final List<Question>? preloadedQuestions;
  
  const QuizScreen({super.key, required this.examId, this.category, this.preloadedQuestions});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late PageController _pageController;
  bool _resultSaved = false;

  @override
  void initState() {
    super.initState();
    // Mevcut ilerlemeyi korumak için mevcut soru indexi ile başlat
    final initialIndex = ref.read(quizControllerProvider).questionIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _questionIndicators({
    required int total,
    required int currentIndex,
    required Map<int, String> selectedAnswers,
    required List<Question> questions,
    required void Function(int) onTap,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(total, (i) {
          final question = questions[i];
          final selected = selectedAnswers[question.id];
          final isCorrect = selected != null && selected == question.correctAnswerKey;
          final isAnswered = selected != null;

          Color bg = AppColors.surfaceContainerHighest;
          BorderSide border = BorderSide(color: AppColors.outline.withValues(alpha: 0.6));
          Widget? icon;

          if (isCorrect) {
            bg = AppColors.success;
            icon = const Icon(Icons.check, size: 14, color: Colors.white);
          } else if (isAnswered && !isCorrect) {
            bg = AppColors.error;
            icon = const Icon(Icons.close, size: 14, color: Colors.white);
          }

          final bool isCurrent = i == currentIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onTap(i),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isCurrent ? 32 : 26,
                height: isCurrent ? 32 : 26,
                decoration: BoxDecoration(
                  color: (isCorrect || (isAnswered && !isCorrect)) ? bg : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isCurrent ? AppColors.primary : border.color, width: isCurrent ? 2 : 1),
                ),
                child: Center(
                  child: icon ?? Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: isCurrent ? 12 : 11,
                      color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _saveResult({required bool isFinal}) async {
    if (_resultSaved) return;
    final quizState = ref.read(quizControllerProvider);
    if (quizState.questions.isEmpty) return;

    final correct = quizState.score;
    final answeredCount = quizState.selectedAnswers.length;
    if (answeredCount == 0) return;

    final totalForThisAttempt = isFinal ? quizState.totalQuestions : answeredCount;
    final category = widget.category ?? 'Karma';

    final result = TestResult(
      date: DateTime.now(),
      correctAnswers: correct,
      totalQuestions: totalForThisAttempt,
      category: category,
    );

    // Persist test result
    await ref.read(userProgressServiceProvider).saveTestResult(result);

    // Handle wrong answer IDs based on test type
    try {
      final questionsById = {for (final q in quizState.questions) q.id: q};
      final ups = ref.read(userProgressServiceProvider);
      
      if (widget.category == 'Yanlışlarım') {
        // In "Yanlışlarım" test: remove correctly answered questions from wrong list
        final List<int> correctlyAnsweredIds = [];
        quizState.selectedAnswers.forEach((questionId, selectedAnswer) {
          final q = questionsById[questionId];
          if (q != null && selectedAnswer == q.correctAnswerKey) {
            correctlyAnsweredIds.add(questionId);
          }
        });
        for (final id in correctlyAnsweredIds) {
          final q = questionsById[id];
          if (q?.examId != null) {
            await ups.removeWrongAnswerPair(examId: q!.examId!, questionId: id);
          } else {
            await ups.removeWrongAnswerId(id); // legacy fallback
          }
        }
      } else {
        // In regular tests: add wrong answers to the wrong list
        final List<int> wrongIds = [];
        quizState.selectedAnswers.forEach((questionId, selectedAnswer) {
          final q = questionsById[questionId];
          if (q != null && selectedAnswer != q.correctAnswerKey) {
            wrongIds.add(questionId);
          }
        });
        for (final id in wrongIds) {
          final q = questionsById[id];
          if (q?.examId != null) {
            await ups.addWrongAnswerPair(examId: q!.examId!, questionId: id);
          } else {
            await ups.addWrongAnswerId(id); // legacy fallback
          }
        }
      }
    } catch (_) {
      // Non-critical: ignore errors when persisting wrong ids
    }
    _resultSaved = true;
  }

  @override
  Widget build(BuildContext context) {
    // If preloadedQuestions provided, bypass provider and use directly
    if (widget.preloadedQuestions != null) {
      final List<Question> base = widget.preloadedQuestions!;
      // When preloaded questions are provided, use them as-is without filtering by category
      final List<Question> questions = base;

      final quizState = ref.watch(quizControllerProvider);
      final bool examChanged = quizState.examId != widget.examId;
      final bool questionCountChanged = quizState.questions.length != questions.length;
      final bool questionsEmpty = quizState.questions.isEmpty;
      
      // Force re-initialization for preloaded questions or when anything changes
      if ((questionsEmpty || questionCountChanged || examChanged) && questions.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Force complete reset
          ref.read(quizControllerProvider.notifier).initializeQuiz(questions, examId: widget.examId);
        });
      }

      if (questions.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.category ?? 'Ehliyet Rehberim'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: const Center(
            child: Text('Bu kategoride soru bulunamadı.'),
          ),
        );
      }

      return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) return;
            await _saveResult(isFinal: false);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                widget.category ?? 'Karma Test',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
              actions: [
                // Display progress
                Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 128),
                    ),
                  ),
                  child: Text(
                    '${quizState.questionIndex + 1} / ${quizState.totalQuestions}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(110),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'İlerleme',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${(quizState.progressPercentage * 100).round()}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: quizState.progressPercentage,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: _questionIndicators(
                          total: quizState.totalQuestions,
                          currentIndex: quizState.questionIndex,
                          selectedAnswers: quizState.selectedAnswers,
                          questions: quizState.questions,
                          onTap: (targetIndex) {
                            ref.read(quizControllerProvider.notifier).setQuestionIndex(targetIndex);
                            _pageController.animateToPage(
                              targetIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: quizState.totalQuestions,
                          onPageChanged: (index) {},
                          itemBuilder: (context, index) {
                            final question = quizState.questions[index];
                            return _QuestionCard(
                              question: question,
                              questionNumber: index + 1,
                              totalQuestions: quizState.totalQuestions,
                              selectedAnswer: quizState.selectedAnswers[question.id],
                              isAnswered: quizState.selectedAnswers.containsKey(question.id),
                              isCorrect: quizState.selectedAnswers[question.id] == question.correctAnswerKey,
                              onAnswerSelected: (answer) {
                                ref.read(quizControllerProvider.notifier).answerQuestion(answer);
                              },
                               onNextQuestion: () {
                                ref.read(quizControllerProvider.notifier).nextQuestion();
                                if (index < quizState.totalQuestions - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                               onPreviousQuestion: () {
                                 if (index > 0) {
                                   ref.read(quizControllerProvider.notifier).previousQuestion();
                                   _pageController.previousPage(
                                     duration: const Duration(milliseconds: 300),
                                     curve: Curves.easeInOut,
                                   );
                                 }
                               },
                              onFinishQuiz: () async {
                                final route = MaterialPageRoute(
                                  builder: (context) => const ResultsScreen(),
                                );
                                final navigator = Navigator.of(context);
                                await _saveResult(isFinal: true);
                                if (mounted) {
                                  navigator.pushReplacement(route);
                                }
                              },
                               autoShowExplainOnWrong: widget.category == 'Yanlışlarım',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (ref.watch(quizControllerProvider).currentCombo >= 3)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: _ComboToast(combo: ref.watch(quizControllerProvider).currentCombo),
                  ),
              ],
            ),
          ),
        );
    }

    // Handle loading and error states for questions (default flow)
    final allQuestionsAsync = ref.watch(quizQuestionsProvider(widget.examId));
    
    return allQuestionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Sorular yüklenirken bir hata oluştu',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(quizQuestionsProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
      data: (allQuestions) {
        // Filter questions by category if specified
        final questions = widget.category != null 
            ? allQuestions.where((q) => q.category == widget.category).toList()
            : allQuestions;
        
        final quizState = ref.watch(quizControllerProvider);

        // Initialize or re-initialize quiz when questions are loaded, changed, or exam changed
        final bool examChanged = quizState.examId != widget.examId;
        final bool questionCountChanged = quizState.questions.length != questions.length;
        final bool questionsEmpty = quizState.questions.isEmpty;
        
        if ((questionsEmpty || questionCountChanged || examChanged) && questions.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(quizControllerProvider.notifier).initializeQuiz(questions, examId: widget.examId);
          });
        }

        // If questions are empty after loading, show a message
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.category ?? 'Ehliyet Rehberim'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: const Center(
              child: Text('Bu kategoride soru bulunamadı.'),
            ),
          );
        }

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) return;
            await _saveResult(isFinal: false);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                widget.category ?? 'Karma Test',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
              actions: [
                // Display progress
                Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 128),
                    ),
                  ),
                  child: Text(
                    '${quizState.questionIndex + 1} / ${quizState.totalQuestions}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(110),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'İlerleme',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${(quizState.progressPercentage * 100).round()}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: quizState.progressPercentage,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: _questionIndicators(
                          total: quizState.totalQuestions,
                          currentIndex: quizState.questionIndex,
                          selectedAnswers: quizState.selectedAnswers,
                          questions: quizState.questions,
                          onTap: (targetIndex) {
                            ref.read(quizControllerProvider.notifier).setQuestionIndex(targetIndex);
                            _pageController.animateToPage(
                              targetIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: quizState.totalQuestions,
                          onPageChanged: (index) {},
                          itemBuilder: (context, index) {
                            final question = quizState.questions[index];
                            return _QuestionCard(
                              question: question,
                              questionNumber: index + 1,
                              totalQuestions: quizState.totalQuestions,
                              selectedAnswer: quizState.selectedAnswers[question.id],
                              isAnswered: quizState.selectedAnswers.containsKey(question.id),
                              isCorrect: quizState.selectedAnswers[question.id] == question.correctAnswerKey,
                              onAnswerSelected: (answer) {
                                ref.read(quizControllerProvider.notifier).answerQuestion(answer);
                              },
                               onNextQuestion: () {
                                ref.read(quizControllerProvider.notifier).nextQuestion();
                                if (index < quizState.totalQuestions - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                               onPreviousQuestion: () {
                                 if (index > 0) {
                                   ref.read(quizControllerProvider.notifier).previousQuestion();
                                   _pageController.previousPage(
                                     duration: const Duration(milliseconds: 300),
                                     curve: Curves.easeInOut,
                                   );
                                 }
                               },
                              onFinishQuiz: () async {
                                final route = MaterialPageRoute(
                                  builder: (context) => const ResultsScreen(),
                                );
                                final navigator = Navigator.of(context);
                                await _saveResult(isFinal: true);
                                if (mounted) {
                                  navigator.pushReplacement(route);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (ref.watch(quizControllerProvider).currentCombo >= 3)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: _ComboToast(combo: ref.watch(quizControllerProvider).currentCombo),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final String? selectedAnswer;
  final bool isAnswered;
  final bool isCorrect;
  final Function(String) onAnswerSelected;
  final VoidCallback onNextQuestion;
  final VoidCallback onPreviousQuestion;
  final VoidCallback onFinishQuiz;
  final bool autoShowExplainOnWrong;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.isAnswered,
    required this.isCorrect,
    required this.onAnswerSelected,
    required this.onNextQuestion,
    required this.onPreviousQuestion,
    required this.onFinishQuiz,
    this.autoShowExplainOnWrong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soru $questionNumber / $totalQuestions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (isAnswered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? AppColors.success : AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isCorrect ? 'Doğru' : 'Yanlış',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCorrect ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (question.imageUrl != null && !question.hasOptionImages) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  question.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: AppColors.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final optionKey = question.options.keys.elementAt(idx);
                final optionValue = question.options.values.elementAt(idx);
                final optionText = question.getOptionText(optionKey);
                final optionImageUrl = question.getOptionImageUrl(optionKey);
                final isSelected = selectedAnswer == optionKey;
                final isCorrectAnswer = optionKey == question.correctAnswerKey;

                Color containerColor = AppColors.surface;
                Color borderColor = AppColors.outline.withValues(alpha: 0.3);
                Widget? trailingIcon;
                Color letterBg = AppColors.surfaceContainerHighest;
                Color letterFg = AppColors.onSurface;

                if (!isAnswered && isSelected) {
                  containerColor = AppColors.primaryContainer;
                  borderColor = AppColors.primary.withValues(alpha: 0.5);
                  letterBg = AppColors.primary;
                  letterFg = AppColors.onPrimary;
                }

                if (isAnswered) {
                  if (isCorrectAnswer) {
                    containerColor = AppColors.successContainer;
                    borderColor = AppColors.success;
                    trailingIcon = Icon(Icons.check_circle, color: AppColors.success);
                    letterBg = AppColors.success;
                    letterFg = AppColors.onSuccess;
                  } else if (isSelected && !isCorrect) {
                    containerColor = AppColors.errorContainer;
                    borderColor = AppColors.error;
                    trailingIcon = Icon(Icons.cancel, color: AppColors.error);
                    letterBg = AppColors.error;
                    letterFg = AppColors.onError;
                  }
                }

                return InkWell(
                  onTap: isAnswered ? null : () => onAnswerSelected(optionKey),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: letterBg,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              optionKey,
                              style: TextStyle(
                                color: letterFg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                            optionText,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: AppColors.textPrimary,
                            ),
                              ),
                              if (optionImageUrl != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: 80,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      optionImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.surfaceContainerHighest,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 24,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Auto show explanation block for Wrong Answers Test when answered incorrectly
          if (isAnswered && !isCorrect && autoShowExplainOnWrong) ...[
            const SizedBox(height: 16),
            // Correct answer indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successContainer.withValues(alpha: 128),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 128),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Doğru Cevap: ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${question.correctAnswerKey.toUpperCase()}) ${question.getOptionText(question.correctAnswerKey)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Explanation text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest.withValues(alpha: 128),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 128),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Açıklama',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation.isNotEmpty
                        ? question.explanation
                        : 'Bu soru için açıklama mevcut değil.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Action buttons section (Explanation button and Prev/Next buttons)
          if (isAnswered) ...[
            const SizedBox(height: 16),
            
            // Explanation button (hide if already auto shown for wrong answer)
            if (!(autoShowExplainOnWrong && !isCorrect))
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showExplanationDialog(context, question),
                icon: Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: AppColors.warning,
                ),
                label: Text(
                  'Açıklamayı Gör',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: AppColors.warning.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppColors.warning.withValues(alpha: 0.08),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Prev/Next buttons row (Prev always visible, disabled for first question)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: questionNumber > 1 ? onPreviousQuestion : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Önceki Soru'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (questionNumber < totalQuestions) {
                        onNextQuestion();
                      } else {
                        onFinishQuiz();
                      }
                    },
                    icon: Icon(questionNumber < totalQuestions ? Icons.arrow_forward : Icons.flag),
                    label: Text(questionNumber < totalQuestions ? 'Sonraki Soru' : 'Testi Bitir'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ]
          else ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: questionNumber > 1 ? onPreviousQuestion : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Önceki Soru'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Show explanation dialog for the current question
  void _showExplanationDialog(BuildContext context, Question question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Açıklama',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest.withValues(alpha: 128),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 128),
                    ),
                  ),
                  child: Text(
                    question.questionText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Correct answer indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer.withValues(alpha: 128),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 128),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Doğru Cevap: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${question.correctAnswerKey.toUpperCase()}) ${question.options[question.correctAnswerKey]}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Explanation text
                Text(
                  'Açıklama:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.explanation.isNotEmpty 
                      ? question.explanation 
                      : 'Bu soru için açıklama mevcut değil.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.check,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                'Anladım',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        );
      },
    );
  }
}

class _ComboToast extends StatefulWidget {
  final int combo;
  const _ComboToast({required this.combo});

  @override
  State<_ComboToast> createState() => _ComboToastState();
}

class _ComboToastState extends State<_ComboToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Auto dismiss
    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                "${widget.combo}'te ${widget.combo}! Harikasın!",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
