import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../models/test_result_model.dart';

/// Service for managing user progress, daily goals, and streaks
/// Uses SharedPreferences for local storage
class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal();

  static UserProgressService get instance => _instance;

  // Stream controllers for real-time updates
  final StreamController<int> _dailyProgressController = StreamController<int>.broadcast();
  final StreamController<int> _streakController = StreamController<int>.broadcast();
  final StreamController<List<TestResult>> _testResultsController = StreamController<List<TestResult>>.broadcast();

  // SharedPreferences keys
  static const String _dailyQuestionsKey = 'daily_questions';
  static const String _lastCompletedDateKey = 'last_completed_date';
  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';
  static const String _totalQuestionsKey = 'total_questions';
  static const String _testResultsKey = 'test_results_v1';
  static const String _wrongAnswerIdsKey = 'wrong_answer_ids_v1';
  static const String _wrongAnswerPairsKey = 'wrong_answer_pairs_v1'; // format: examId:questionId

  // Daily goal configuration
  static const int _dailyGoal = 50; // Questions per day

  /// Stream that emits the number of questions answered today
  Stream<int> get dailyProgressStream => _dailyProgressController.stream;

  /// Stream that emits the current streak count
  Stream<int> get streakStream => _streakController.stream;

  /// Stream that emits the current list of test results
  Stream<List<TestResult>> get resultsStream => _testResultsController.stream;

  /// Get the current daily progress
  Future<int> get dailyProgress async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();
    final lastCompletedDate = prefs.getString(_lastCompletedDateKey);
    
    // If it's a new day, reset daily progress
    if (lastCompletedDate != today) {
      return 0;
    }
    
    return prefs.getInt(_dailyQuestionsKey) ?? 0;
  }

  /// Get the current streak count
  Future<int> get currentStreak async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  // ================================
  // Wrong Answers Persistence
  // ================================

  /// Add a question ID to the persistent list of wrong answers (unique)
  Future<void> addWrongAnswerId(int questionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> existing = prefs.getStringList(_wrongAnswerIdsKey) ?? <String>[];
      final Set<int> currentIds = existing.map(int.parse).toSet();
      if (!currentIds.contains(questionId)) {
        currentIds.add(questionId);
        final List<String> toStore = currentIds.map((e) => e.toString()).toList();
        await prefs.setStringList(_wrongAnswerIdsKey, toStore);
        Logger.info('Added wrong answer id: $questionId (total: ${toStore.length})');
      }
    } catch (e) {
      Logger.error('Failed to add wrong answer id: $questionId', e);
    }
  }

  /// Add an examId+questionId pair to persistent wrong answers (unique)
  Future<void> addWrongAnswerPair({required String examId, required int questionId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> existing = prefs.getStringList(_wrongAnswerPairsKey) ?? <String>[];
      final String key = '$examId:$questionId';
      if (!existing.contains(key)) {
        existing.add(key);
        await prefs.setStringList(_wrongAnswerPairsKey, existing);
        Logger.info('Added wrong answer pair: $key (total: ${existing.length})');
      }
    } catch (e) {
      Logger.error('Failed to add wrong answer pair: $examId:$questionId', e);
    }
  }

  /// Retrieve the list of saved wrong answer IDs
  Future<List<int>> getWrongAnswerIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> existing = prefs.getStringList(_wrongAnswerIdsKey) ?? <String>[];
      return existing.map(int.parse).toList(growable: false);
    } catch (e) {
      Logger.error('Failed to load wrong answer ids', e);
      return <int>[];
    }
  }

  /// Retrieve the list of saved wrong answer pairs (examId:questionId)
  Future<List<String>> getWrongAnswerPairs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_wrongAnswerPairsKey) ?? <String>[];
    } catch (e) {
      Logger.error('Failed to load wrong answer pairs', e);
      return <String>[];
    }
  }

  /// Remove a specific wrong answer ID (when user gets it right)
  Future<void> removeWrongAnswerId(int questionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> existing = prefs.getStringList(_wrongAnswerIdsKey) ?? <String>[];
      final Set<int> currentIds = existing.map(int.parse).toSet();
      if (currentIds.contains(questionId)) {
        currentIds.remove(questionId);
        final List<String> toStore = currentIds.map((e) => e.toString()).toList();
        await prefs.setStringList(_wrongAnswerIdsKey, toStore);
        Logger.info('Removed wrong answer id: $questionId (remaining: ${toStore.length})');
      }
    } catch (e) {
      Logger.error('Failed to remove wrong answer id: $questionId', e);
    }
  }

  /// Remove a specific wrong answer pair
  Future<void> removeWrongAnswerPair({required String examId, required int questionId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> existing = prefs.getStringList(_wrongAnswerPairsKey) ?? <String>[];
      final String key = '$examId:$questionId';
      if (existing.contains(key)) {
        existing.remove(key);
        await prefs.setStringList(_wrongAnswerPairsKey, existing);
        Logger.info('Removed wrong answer pair: $key (remaining: ${existing.length})');
      }
    } catch (e) {
      Logger.error('Failed to remove wrong answer pair: $examId:$questionId', e);
    }
  }

  /// Clear all wrong answer IDs
  Future<void> clearAllWrongAnswerIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wrongAnswerIdsKey);
      Logger.info('Cleared all wrong answer ids');
    } catch (e) {
      Logger.error('Failed to clear wrong answer ids', e);
    }
  }

  /// Clear all wrong answer pairs
  Future<void> clearAllWrongAnswerPairs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wrongAnswerPairsKey);
      Logger.info('Cleared all wrong answer pairs');
    } catch (e) {
      Logger.error('Failed to clear wrong answer pairs', e);
    }
  }

  /// Debug: Get count of stored wrong IDs
  Future<int> getWrongAnswerIdsCount() async {
    try {
      final ids = await getWrongAnswerIds();
      final pairs = await getWrongAnswerPairs();
      Logger.info('Current wrong answer IDs count: ${ids.length}, Pairs count: ${pairs.length}');
      return pairs.isNotEmpty ? pairs.length : ids.length;
    } catch (e) {
      Logger.error('Failed to get wrong answer ids count', e);
      return 0;
    }
  }

  /// Get the longest streak achieved
  Future<int> get longestStreak async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_longestStreakKey) ?? 0;
  }

  /// Get total questions answered
  Future<int> get totalQuestions async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalQuestionsKey) ?? 0;
  }

  /// Called when a user completes a question
  Future<void> completeQuestion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();
      final lastCompletedDate = prefs.getString(_lastCompletedDateKey);
      
      // Get current values
      int dailyQuestions = prefs.getInt(_dailyQuestionsKey) ?? 0;
      int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
      int totalQuestions = prefs.getInt(_totalQuestionsKey) ?? 0;
      
      // Check if it's a new day
      if (lastCompletedDate != today) {
        // Check if yesterday was completed (for streak calculation)
        final yesterday = _getYesterdayString();
        if (lastCompletedDate == yesterday) {
          // Continue streak
          currentStreak++;
        } else {
          // Break in streak, reset to 1
          currentStreak = 1;
        }
        
        // Reset daily questions for new day
        dailyQuestions = 0;
      }
      
      // Increment counters
      dailyQuestions++;
      totalQuestions++;
      
      // Update longest streak if current streak is longer
      final longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
      if (currentStreak > longestStreak) {
        await prefs.setInt(_longestStreakKey, currentStreak);
      }
      
      // Save updated values
      await prefs.setInt(_dailyQuestionsKey, dailyQuestions);
      await prefs.setString(_lastCompletedDateKey, today);
      await prefs.setInt(_currentStreakKey, currentStreak);
      await prefs.setInt(_totalQuestionsKey, totalQuestions);
      
      // Emit updated values
      _dailyProgressController.add(dailyQuestions);
      _streakController.add(currentStreak);
      
      Logger.info('Question completed. Daily: $dailyQuestions/$_dailyGoal, Streak: $currentStreak');
      
      // Check if daily goal is met
      await _checkDailyGoal();
      
    } catch (e) {
      Logger.error('Failed to complete question', e);
    }
  }

  /// Check if daily goal is met and update streak
  Future<void> _checkDailyGoal() async {
    try {
      final dailyProgress = await this.dailyProgress;
      if (dailyProgress >= _dailyGoal) {
        Logger.info('Daily goal achieved! $dailyProgress/$_dailyGoal questions completed');
        // You can add additional rewards or notifications here
      }
    } catch (e) {
      Logger.error('Failed to check daily goal', e);
    }
  }

  /// Reset daily progress (useful for testing or manual reset)
  Future<void> resetDailyProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyQuestionsKey, 0);
      _dailyProgressController.add(0);
      Logger.info('Daily progress reset');
    } catch (e) {
      Logger.error('Failed to reset daily progress', e);
    }
  }

  /// Reset streak (useful for testing or manual reset)
  Future<void> resetStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentStreakKey, 0);
      _streakController.add(0);
      Logger.info('Streak reset');
    } catch (e) {
      Logger.error('Failed to reset streak', e);
    }
  }

  /// Get today's date as a string (YYYY-MM-DD format)
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get yesterday's date as a string (YYYY-MM-DD format)
  String _getYesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  /// Initialize the service and load current values
  Future<void> initialize() async {
    if (_isInitialized) return; // Prevent double initialization
    
    try {
      // Load current values and emit them
      final dailyProgress = await this.dailyProgress;
      final currentStreak = await this.currentStreak;
      
      _dailyProgressController.add(dailyProgress);
      _streakController.add(currentStreak);
      
      // Load test results and emit to stream
      await _loadTestResults();
      
      _isInitialized = true;
      Logger.info('UserProgressService initialized. Daily: $dailyProgress, Streak: $currentStreak, Results: ${_cachedResults.length}');
    } catch (e) {
      Logger.error('Failed to initialize UserProgressService', e);
      // Even if there's an error, emit empty results to prevent infinite loading
      _cachedResults = [];
      _testResultsController.add([]);
      _isInitialized = true; // Mark as initialized even if failed
    }
  }

  /// Check if service is already initialized
  bool _isInitialized = false;

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Force refresh the test results (useful for manual refresh)
  Future<void> refreshTestResults() async {
    await _loadTestResults();
  }

  /// Dispose the service and close streams
  void dispose() {
    _dailyProgressController.close();
    _streakController.close();
    _testResultsController.close();
  }

  // ================================
  // Test Results Persistence
  // ================================

  /// Save a completed quiz result
  Future<void> saveTestResult(TestResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_testResultsKey);
      final List<TestResult> list = existing == null || existing.isEmpty
          ? <TestResult>[]
          : TestResult.decodeList(existing);
      list.add(result);
      await prefs.setString(_testResultsKey, TestResult.encodeList(list));
      // Update cache and emit updated list to all listeners
      _cachedResults = list;
      _testResultsController.add(list);
      Logger.info('Saved test result: ${result.correctAnswers}/${result.totalQuestions} (${result.category}). Total results: ${list.length}');
    } catch (e) {
      Logger.error('Failed to save test result', e);
    }
  }

  // Cache for results to make getAllTestResults synchronous
  List<TestResult> _cachedResults = [];

  /// Retrieve all saved quiz results (synchronous)
  List<TestResult> getAllTestResults({String? examId}) {
    // This method is now synchronous and returns cached results
    // The stream will handle updates
    if (examId == null) return _cachedResults;
    return _cachedResults.where((r) => r.examId == examId).toList();
  }

  /// Load test results from storage and emit to stream
  Future<void> _loadTestResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_testResultsKey);
      final results = jsonStr == null || jsonStr.isEmpty 
          ? <TestResult>[]
          : TestResult.decodeList(jsonStr);
      _cachedResults = results;
      _testResultsController.add(results);
      Logger.info('Loaded ${results.length} test results from storage and emitted to stream');
    } catch (e) {
      Logger.error('Failed to load test results', e);
      _cachedResults = [];
      _testResultsController.add([]);
    }
  }
} 