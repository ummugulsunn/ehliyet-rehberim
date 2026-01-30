import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../application/quiz_providers.dart';
import '../domain/question_model.dart';
import 'results_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/test_result_model.dart';
import 'widgets/exam_timer_widget.dart';
import '../../favorites/application/favorites_providers.dart';
import 'widgets/vimeo_player_widget.dart';
import '../domain/unfinished_exam.dart';
import '../data/exam_storage_service.dart';
import '../application/quiz_state.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String examId;
  final String? category;
  final List<Question>? preloadedQuestions;
  final bool isExamMode;
  
  const QuizScreen({
    super.key,
    required this.examId,
    this.category,
    this.preloadedQuestions,
    this.isExamMode = false,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late PageController _pageController;
  late ConfettiController _confettiController;
  bool _resultSaved = false;

  @override
  void initState() {
    super.initState();
    // Her kategori değişiminde sıfırdan başlat
    _pageController = PageController(initialPage: 0);
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    
    // Check for unfinished exam only in Exam Mode
    if (widget.isExamMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUnfinishedExam();
      });
    }
  }

  Future<void> _checkForUnfinishedExam() async {
    final storage = ref.read(examStorageServiceProvider);
    final unfinished = await storage.getUnfinishedExam(widget.examId);
    
    if (unfinished != null && mounted) {
      // Show dialog asking to resume
      final shouldResume = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Yarım Kalan Sınav'),
          content: Text(
            'Bu sınavda daha önce ${unfinished.currentQuestionIndex + 1}. soruda kalmıştınız.\n\nKaldığınız yerden devam etmek ister misiniz?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Delete saved data and start fresh
                storage.deleteUnfinishedExam(widget.examId);
                Navigator.of(context).pop(false);
              },
              child: const Text('Hayır, Baştan Başla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Evet, Devam Et'),
            ),
          ],
        ),
      );
      
      if (shouldResume == true && mounted) {
        // Restore state
        final controller = ref.read(quizControllerProvider(widget.examId).notifier);
        
        // Convert Map<String, String> to Map<int, String>
        final Map<int, String> answers = {};
        unfinished.answers.forEach((key, value) {
          final intKey = int.tryParse(key);
          if (intKey != null) {
            answers[intKey] = value;
          }
        });
        
        controller.restoreState(
          index: unfinished.currentQuestionIndex,
          answers: answers,
          remainingSeconds: unfinished.remainingSeconds,
        );
        
        // Jump to page
        _pageController.jumpToPage(unfinished.currentQuestionIndex);
      } else {
        // Ensure old data is cleared if they chose to restart
         await storage.deleteUnfinishedExam(widget.examId);
      }
    }
  }

  Future<void> _onExitPressed() async {
     // If not in exam mode or result already saved/finished, just pop
    final state = ref.read(quizControllerProvider(widget.examId));
    
    // For non-exam mode (Karma, Wrong Answers, etc.), we MUST save before exiting
    // to ensure wrong answers (or corrections) are persisted.
    if (!widget.isExamMode) {
      if (!_resultSaved && state.status != QuizStatus.complete && state.selectedAnswers.isNotEmpty) {
        // Save partial result logic
        await _saveResult(isFinal: false);
      }
      if (mounted) Navigator.of(context).pop();
      return;
    }

    if (_resultSaved || state.status == QuizStatus.complete) {
      Navigator.of(context).pop();
      return;
    }
    
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sınavdan Çıkılıyor'),
        content: const Text('Ne yapmak istersiniz?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
             onPressed: () => Navigator.of(context).pop('cancel'),
             child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('finish'),
             child: const Text('Bitir'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('Kaydet ve Çık'),
          ),
        ],
      ),
    );
    
    if (!mounted) return;
    
    if (action == 'save') {
       await _saveAndExit();
    } else if (action == 'finish') {
       // Finish exam logic
       ref.read(quizControllerProvider(widget.examId).notifier).finishExam();
       await _saveResult(isFinal: true);
       if (mounted) {
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(
              builder: (_) => ResultsScreen(
                examId: widget.examId,
                result: TestResult(
                  date: DateTime.now(), 
                  correctAnswers: state.score, 
                  totalQuestions: state.totalQuestions, 
                  category: widget.category ?? 'Genel', 
                  examId: widget.examId, 
                  selectedAnswers: state.selectedAnswers,
                  isExamMode: true,
                  isPassed: state.score >= 35, // Approx 70% of 50
                ),
              ),
           ),
         );
       }
    }
  }

  Future<void> _saveAndExit() async {
    final state = ref.read(quizControllerProvider(widget.examId));
    final storage = ref.read(examStorageServiceProvider);
    
    // Map<int, String> to Map<String, String>
    final answers = state.selectedAnswers.map((k, v) => MapEntry(k.toString(), v));
    
    final unfinished = UnfinishedExam(
      examId: widget.examId,
      currentQuestionIndex: state.questionIndex,
      remainingSeconds: state.examTimeRemaining?.inSeconds ?? 0,
      answers: answers,
      savedAt: DateTime.now(),
    );
    
    await storage.saveExam(unfinished);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sınav kaydedildi. Daha sonra devam edebilirsiniz.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
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

          Color bg = Theme.of(context).colorScheme.surfaceContainerHighest;
          BorderSide border = BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6));
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
                  color: (isCorrect || (isAnswered && !isCorrect)) ? bg : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isCurrent ? AppColors.primary : border.color, width: isCurrent ? 2 : 1),
                ),
                child: Center(
                  child: icon ?? Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: isCurrent ? 12 : 11,
                      color: isCurrent ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
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
    final quizState = ref.read(quizControllerProvider(widget.examId));
    if (quizState.questions.isEmpty) return;

    final correct = quizState.score;
    final answeredCount = quizState.selectedAnswers.length;
    if (answeredCount == 0) return;

    final totalForThisAttempt = isFinal ? quizState.totalQuestions : answeredCount;
    final category = widget.category ?? 'Karma';

    final timeTaken = widget.isExamMode 
        ? ref.read(quizControllerProvider(widget.examId).notifier).getTimeTaken() 
        : null;

    final result = TestResult(
      date: DateTime.now(),
      correctAnswers: correct,
      totalQuestions: totalForThisAttempt,
      category: category,
      examId: widget.examId,
      selectedAnswers: quizState.selectedAnswers,
      isExamMode: widget.isExamMode,
      timeTakenInSeconds: timeTaken?.inSeconds,
      isPassed: widget.isExamMode ? (correct / totalForThisAttempt >= 0.7) : null,
    );

    // Persist test result
    await ref.read(userProgressRepositoryProvider).saveTestResult(result);

    // Handle wrong answer IDs based on test type
    try {
      final questionsById = {for (final q in quizState.questions) q.id: q};
      final ups = ref.read(userProgressRepositoryProvider);
      
        if (widget.category == 'Yanlışlarım') {
        // In "Yanlışlarım" test: update SRS status for ALL answered questions
        for (final entry in quizState.selectedAnswers.entries) {
           final questionId = entry.key;
           final selectedAnswer = entry.value;
           final q = questionsById[questionId];
           
           if (q != null && q.examId != null) {
              final isCorrect = selectedAnswer == q.correctAnswerKey;
              // Updates SRS (promotes if correct, resets if wrong)
              await ups.updateSRSStatus(
                examId: q.examId!, 
                questionId: q.originalQuestionId ?? questionId, // Use original ID if available
                isCorrect: isCorrect
              );
           }
        }
      } else {
        // In regular tests: add wrong answers to the wrong list (SRS Level 0)
        for (final entry in quizState.selectedAnswers.entries) {
          final questionId = entry.key;
          final selectedAnswer = entry.value;
          final q = questionsById[questionId];
          
          if (q != null && selectedAnswer != q.correctAnswerKey) {
             // WRONG Answer -> Add to SRS
             if (q.examId != null) {
               await ups.updateSRSStatus(
                 examId: q.examId!, 
                 questionId: q.originalQuestionId ?? questionId, // Use original ID if available 
                 isCorrect: false
               );
             } else {
               // Fallback for questions without examId
               await ups.addWrongAnswerId(q.originalQuestionId ?? questionId); 
             }
          }
        }
      }
    } catch (_) {
      // Non-critical: ignore errors when persisting wrong ids
    }
    _resultSaved = true;
  }

  Future<void> _confirmFinishExam(BuildContext context) async {
    final quizState = ref.read(quizControllerProvider(widget.examId));
    final answeredCount = quizState.selectedAnswers.length;
    final totalCount = quizState.totalQuestions;
    final unaskedCount = totalCount - answeredCount;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sınavı Bitir?'),
        content: Text(
          unaskedCount > 0
              ? 'Henüz cevaplamadığınız $unaskedCount soru var. Sınavı bitirmek istediğinize emin misiniz?'
              : 'Sınavı bitirmek ve sonuçları görmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sınavı Bitir'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _saveResult(isFinal: true);
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultsScreen(examId: widget.examId),
          ),
        );
      }
    }
  }

  Future<void> _showNoteDialog(BuildContext context, int questionId) async {
    final currentNote = ref.read(questionNoteProvider(questionId));
    final noteController = TextEditingController(text: currentNote);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Ekle / Düzenle'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Bu soru için notunuzu girin...',
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
              ref.read(favoritesRepositoryProvider).saveNote(questionId, noteController.text);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Not kaydedildi'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If preloadedQuestions provided, bypass provider and use directly
    if (widget.preloadedQuestions != null) {
      final List<Question> base = widget.preloadedQuestions!;
      // When preloaded questions are provided, use them as-is without filtering by category
      final List<Question> questions = base;

    final quizState = ref.watch(quizControllerProvider(widget.examId));
      final bool examChanged = quizState.examId != widget.examId;
      // final bool questionCountChanged = quizState.questions.length != questions.length;
      final bool questionsEmpty = quizState.questions.isEmpty;

      // Only initialize if quiz state is truly empty or exam changed
      // Don't reinitialize if questions are already loaded and exam is the same
      if (questionsEmpty && questions.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final notifier = ref.read(quizControllerProvider(widget.examId).notifier);
          notifier.initializeQuiz(questions, examId: widget.examId);
          if (widget.isExamMode) {
            notifier.startExamMode();
          }
        });
      } else if (examChanged && questions.isNotEmpty) {
        // Only reinitialize if exam changed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final notifier = ref.read(quizControllerProvider(widget.examId).notifier);
          notifier.initializeQuiz(questions, examId: widget.examId);
          if (widget.isExamMode) {
            notifier.startExamMode();
          }
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
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _onExitPressed();
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                widget.category ?? 'Karma Test',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              leading: widget.isExamMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _onExitPressed,
                  )
                : const BackButton(),
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
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                            ref.read(quizControllerProvider(widget.examId).notifier).setQuestionIndex(targetIndex);
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
                          onPageChanged: (index) {
                            // PageView değiştiğinde quiz state'i sync et
                            ref.read(quizControllerProvider(widget.examId).notifier).setQuestionIndex(index);
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
                              isExamMode: widget.isExamMode,
                              onAnswerSelected: (answer) {
                                ref.read(quizControllerProvider(widget.examId).notifier).answerQuestion(answer);
                                // Trigger confetti animation for correct answers only in normal mode
                                if (!widget.isExamMode) {
                                  final currentQuestion = quizState.questions[index];
                                  if (answer == currentQuestion.correctAnswerKey) {
                                    _confettiController.play();
                                  }
                                }
                              },
                               onNextQuestion: () {
                                ref.read(quizControllerProvider(widget.examId).notifier).nextQuestion();
                                if (index < quizState.totalQuestions - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                               onPreviousQuestion: () {
                                 if (index > 0) {
                                   ref.read(quizControllerProvider(widget.examId).notifier).previousQuestion();
                                   _pageController.previousPage(
                                     duration: const Duration(milliseconds: 300),
                                     curve: Curves.easeInOut,
                                   );
                                 }
                                },
                              onFinishQuiz: () async {
                                if (widget.isExamMode) {
                                  _confirmFinishExam(context);
                                } else {
                                  final route = MaterialPageRoute(
                                    builder: (context) => ResultsScreen(examId: widget.examId),
                                  );
                                  final navigator = Navigator.of(context);
                                  await _saveResult(isFinal: true);
                                  if (mounted) {
                                    navigator.pushReplacement(route);
                                  }
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
                if (ref.watch(quizControllerProvider(widget.examId)).currentCombo >= 3)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: _ComboToast(combo: ref.watch(quizControllerProvider(widget.examId)).currentCombo),
                  ),
                // Confetti animation for correct answers
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: [
                      AppColors.success,
                      AppColors.primary,
                      AppColors.warning,
                      const Color(0xFFFFD700), // Gold
                      const Color(0xFFFF69B4), // Hot pink
                    ],
                    numberOfParticles: 20,
                    gravity: 0.3,
                  ),
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
        
        final quizState = ref.watch(quizControllerProvider(widget.examId));

        // Initialize or re-initialize quiz only when necessary
        final bool examChanged = quizState.examId != widget.examId;
        final bool questionsEmpty = quizState.questions.isEmpty;
        
        // Only initialize if quiz state is truly empty or exam changed
        if (questionsEmpty && questions.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final notifier = ref.read(quizControllerProvider(widget.examId).notifier);
            notifier.initializeQuiz(questions, examId: widget.examId);
            if (widget.isExamMode) {
              notifier.startExamMode();
            }
          });
        } else if (examChanged && questions.isNotEmpty) {
          // Only reinitialize if exam changed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final notifier = ref.read(quizControllerProvider(widget.examId).notifier);
            notifier.initializeQuiz(questions, examId: widget.examId);
            if (widget.isExamMode) {
              notifier.startExamMode();
            }
          });
        }

    // If questions are empty after loading, show a message
        if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isExamMode ? 'Sınav Simülasyonu' : (widget.category ?? 'Ehliyet Rehberim')),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Text('Bu kategoride soru bulunamadı.'),
        ),
      );
    }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _onExitPressed();
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
              title: Text(
                widget.isExamMode ? 'Sınav Simülasyonu' : (widget.category ?? 'Karma Test'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              leading: widget.isExamMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _onExitPressed,
                  )
                : const BackButton(),
            actions: [
              // Favorite Button
              if (quizState.questions.isNotEmpty)
                Consumer(
                  builder: (context, ref, child) {
                    final currentQ = quizState.questions[quizState.questionIndex];
                    final isFav = ref.watch(isFavoriteProvider(currentQ.id));
                    
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.error : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        ref.read(favoritesRepositoryProvider).toggleFavorite(currentQ.id);
                      },
                      onLongPress: () => _showNoteDialog(context, currentQ.id),
                      tooltip: isFav ? 'Favorilerden Çıkar (Not için basılı tut)' : 'Favorilere Ekle (Not için basılı tut)',
                    );
                  },
                ),
              if (widget.isExamMode)
                TextButton(
                  onPressed: () => _confirmFinishExam(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Bitir',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
                preferredSize: Size.fromHeight(widget.isExamMode ? 170 : 110),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    children: [
                      if (widget.isExamMode) ...[
                        ExamTimerWidget(
                          // Key ensures widget is rebuilt when exam session changes or is restored
                          key: ValueKey(quizState.examStartTime),
                          duration: quizState.examTimeRemaining ?? const Duration(minutes: 30),
                          onTimeUp: () {
                            ref.read(quizControllerProvider(widget.examId).notifier).finishExam();
                            // Navigate to results screen
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ResultsScreen(examId: widget.examId),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'İlerleme',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                            ref.read(quizControllerProvider(widget.examId).notifier).setQuestionIndex(targetIndex);
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
                  onPageChanged: (index) {
                            // PageView değiştiğinde quiz state'i sync et
                            ref.read(quizControllerProvider(widget.examId).notifier).setQuestionIndex(index);
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
                      isExamMode: widget.isExamMode,
                      onAnswerSelected: (answer) {
                        ref.read(quizControllerProvider(widget.examId).notifier).answerQuestion(answer);
                        // Trigger confetti animation for correct answers only in normal mode
                        if (!widget.isExamMode) {
                          final currentQuestion = quizState.questions[index];
                          if (answer == currentQuestion.correctAnswerKey) {
                            _confettiController.play();
                          }
                        }
                      },
                      onNextQuestion: () {
                        ref.read(quizControllerProvider(widget.examId).notifier).nextQuestion();
                        if (index < quizState.totalQuestions - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                               onPreviousQuestion: () {
                                 if (index > 0) {
                                   ref.read(quizControllerProvider(widget.examId).notifier).previousQuestion();
                                   _pageController.previousPage(
                                     duration: const Duration(milliseconds: 300),
                                     curve: Curves.easeInOut,
                                   );
                                 }
                               },
                              onFinishQuiz: () async {
                                final route = MaterialPageRoute(
                                  builder: (context) => ResultsScreen(examId: widget.examId),
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
                if (ref.watch(quizControllerProvider(widget.examId)).currentCombo >= 3)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: _ComboToast(combo: ref.watch(quizControllerProvider(widget.examId)).currentCombo),
                  ),
                // Confetti animation for correct answers
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: [
                      AppColors.success,
                      AppColors.primary,
                      AppColors.warning,
                      const Color(0xFFFFD700), // Gold
                      const Color(0xFFFF69B4), // Hot pink
                    ],
                    numberOfParticles: 20,
                    gravity: 0.3,
                  ),
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
  final bool isExamMode;

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
    this.isExamMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 50,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        AppColors.primary.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                'Soru $questionNumber / $totalQuestions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                ),
              ),
              if (isAnswered && !isExamMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                          (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.08),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: isCorrect ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCorrect ? 'Doğru' : 'Yanlış',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isCorrect ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (question.imageUrl != null && !question.hasOptionImages) ...[
            // Check if it's a video URL
            if (isVideoUrl(question.imageUrl))
              VimeoPlayerWidget(
                videoUrl: question.imageUrl!,
                height: 200,
              )
            else
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: question.imageUrl!.startsWith('http')
                        ? Image.network(
                            question.imageUrl!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            question.imageUrl!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.contain,
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) return child;
                              if (frame == null) {
                                return Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              }
                              return child;
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          // Options list should size to its content so that the whole card can scroll
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final optionKey = question.options.keys.elementAt(idx);
                final optionText = question.getOptionText(optionKey);
                final optionImageUrl = question.getOptionImageUrl(optionKey);
                final isSelected = selectedAnswer == optionKey;
                final isCorrectAnswer = optionKey == question.correctAnswerKey;
                
                Color containerColor = Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.surface;
                Color borderColor = Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.6)
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
                Widget? trailingIcon;
                Color letterBg = Theme.of(context).colorScheme.surfaceContainerHighest;
                Color letterFg = Theme.of(context).colorScheme.onSurface;

                if (isAnswered && !isExamMode) {
                  if (isCorrectAnswer) {
                    containerColor = Theme.of(context).brightness == Brightness.dark
                        ? AppColors.successContainer.withValues(alpha: 0.3)
                        : AppColors.successContainer;
                    borderColor = AppColors.success;
                    trailingIcon = Icon(Icons.check_circle, color: AppColors.success);
                    letterBg = AppColors.success;
                    letterFg = AppColors.onSuccess;
                  } else if (isSelected && !isCorrect) {
                    containerColor = Theme.of(context).brightness == Brightness.dark
                        ? AppColors.errorContainer.withValues(alpha: 0.3)
                        : AppColors.errorContainer;
                    borderColor = AppColors.error;
                    trailingIcon = Icon(Icons.cancel, color: AppColors.error);
                    letterBg = AppColors.error;
                    letterFg = AppColors.onError;
                  }
                } else if (isSelected) {
                  containerColor = Theme.of(context).brightness == Brightness.dark
                      ? AppColors.primaryContainer.withValues(alpha: 0.3)
                      : AppColors.primaryContainer;
                  borderColor = AppColors.primary.withValues(alpha: 0.8);
                  letterBg = AppColors.primary;
                  letterFg = AppColors.onPrimary;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: (isAnswered && !isExamMode) ? null : () => onAnswerSelected(optionKey),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              containerColor,
                              containerColor.withValues(alpha: 0.95),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: isSelected || isAnswered ? 2 : 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 1,
                            ),
                            if (isSelected || isCorrectAnswer)
                              BoxShadow(
                                color: borderColor.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                          ],
                      ),
                      child: Row(
                        children: [
                          Container(
                          width: 36,
                          height: 36,
                            decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                letterBg,
                                letterBg.withValues(alpha: 0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                              shape: BoxShape.circle,
                            border: Border.all(
                              color: letterFg.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: letterBg.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            ),
                            child: Center(
                              child: Text(
                                optionKey,
                                style: TextStyle(
                                color: letterFg,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
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
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.95)
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                              ),
                              if (optionImageUrl != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: 80,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: optionImageUrl.startsWith('http')
                                        ? Image.network(
                                            optionImageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 24,
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            optionImageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 24,
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    ),
                  ),
                );
              },
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
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 128),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Açıklama',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation.isNotEmpty
                        ? question.explanation
                        : 'Bu soru için açıklama mevcut değil.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Action buttons section (Explanation button and Prev/Next buttons)
          if (isAnswered || isExamMode) ...[
            const SizedBox(height: 16),
            
            // Explanation button (Only in normal mode when answered)
            if (!isExamMode && isAnswered && !(autoShowExplainOnWrong && !isCorrect))
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
          else if (!isExamMode) ...[
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
                    color: Theme.of(context).colorScheme.onSurface,
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
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 128),
                    ),
                  ),
                  child: Text(
                    question.questionText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.explanation.isNotEmpty 
                      ? question.explanation 
                      : 'Bu soru için açıklama mevcut değil.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
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
