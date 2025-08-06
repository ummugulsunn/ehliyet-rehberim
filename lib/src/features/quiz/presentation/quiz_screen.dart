import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/quiz_providers.dart';
import '../../../core/models/question_model.dart';
import 'results_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String? category;
  
  const QuizScreen({super.key, this.category});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(quizQuestionsProvider(widget.category));
    final quizState = ref.watch(quizControllerProvider);

    return questionsAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
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
                onPressed: () {
                  ref.invalidate(quizQuestionsProvider(widget.category));
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
      data: (questions) {
        // Initialize quiz if not already done
        if (quizState.questions.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(quizControllerProvider.notifier).initializeQuiz(questions);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.category ?? 'Ehliyet Rehberim'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              // Display progress
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '${quizState.questionIndex + 1} / ${quizState.totalQuestions}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: quizState.progressPercentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              // PageView for questions
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: quizState.totalQuestions,
                  onPageChanged: (index) {
                    // Update quiz state when page changes
                    if (index != quizState.questionIndex) {
                      // This will be handled by the quiz controller
                    }
                  },
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
                    );
                  },
                ),
              ),
            ],
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

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.isAnswered,
    required this.isCorrect,
    required this.onAnswerSelected,
    required this.onNextQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soru $questionNumber / $totalQuestions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (isAnswered)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Question image (if exists)
          if (question.imageUrl != null) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  question.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Question text
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          
          // Answer options
          Expanded(
            child: Column(
              children: question.options.entries.map((entry) {
                final optionKey = entry.key;
                final optionText = entry.value;
                final isSelected = selectedAnswer == optionKey;
                final isCorrectAnswer = optionKey == question.correctAnswerKey;
                
                Color? buttonColor;
                if (isAnswered) {
                  if (isCorrectAnswer) {
                    buttonColor = Colors.green[100];
                  } else if (isSelected && !isCorrect) {
                    buttonColor = Colors.red[100];
                  }
                } else if (isSelected) {
                  buttonColor = Theme.of(context).colorScheme.primaryContainer;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isAnswered ? null : () => onAnswerSelected(optionKey),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isAnswered && isCorrectAnswer 
                                ? Colors.green 
                                : (isSelected && !isCorrect ? Colors.red : Colors.grey[300]!),
                            width: isAnswered && (isCorrectAnswer || (isSelected && !isCorrect)) ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isAnswered && isCorrectAnswer 
                                  ? Colors.green 
                                  : (isSelected && !isCorrect ? Colors.red : Colors.grey[300]),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                optionKey,
                                style: TextStyle(
                                  color: isAnswered && isCorrectAnswer 
                                      ? Colors.white 
                                      : (isSelected && !isCorrect ? Colors.white : Colors.black87),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              optionText,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isAnswered && isCorrectAnswer)
                            const Icon(Icons.check, color: Colors.green),
                          if (isSelected && !isCorrect)
                            const Icon(Icons.close, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Next question or finish quiz button
          if (isAnswered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (questionNumber < totalQuestions) {
                    // Next question
                    onNextQuestion();
                  } else {
                    // Finish quiz and navigate to results
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ResultsScreen(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  questionNumber < totalQuestions ? 'Sonraki Soru' : 'Testi Bitir',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 