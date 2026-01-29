import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/logger.dart';
import '../../quiz/domain/test_result_model.dart';
import '../../home/domain/achievement_model.dart';

/// Repository for managing user progress, daily goals, and streaks
/// Uses SharedPreferences for local storage
class UserProgressRepository {
  static final UserProgressRepository _instance = UserProgressRepository._internal();
  factory UserProgressRepository() => _instance;
  // Cached values for Stream replay
  int _currentDailyProgress = 0;
  int _currentStreak = 0;
  int _currentXP = 0;
  int _currentLevel = 1;

  // Stream controllers with replay capability
  late final StreamController<UserProgressState> _stateController;
  final StreamController<List<TestResult>> _testResultsController = StreamController<List<TestResult>>.broadcast();

  // Deprecated individual controllers - kept for backward compatibility if needed, 
  // but we should migrate to stateController
  late final StreamController<int> _dailyProgressController;
  late final StreamController<int> _streakController;
  late final StreamController<int> _xpController;
  late final StreamController<int> _levelController;

  UserProgressRepository._internal() {
    _stateController = StreamController<UserProgressState>.broadcast();
    _dailyProgressController = StreamController<int>.broadcast();
    _streakController = StreamController<int>.broadcast();
    _xpController = StreamController<int>.broadcast();
    _levelController = StreamController<int>.broadcast();
    _achievementsController = StreamController<List<String>>.broadcast();
  }

  static UserProgressRepository get instance => _instance;

  // Achievement related fields
  final StreamController<List<String>> _achievementsController = StreamController<List<String>>.broadcast();

  // SharedPreferences keys
  static const String _dailyQuestionsKey = 'daily_questions';
  static const String _lastCompletedDateKey = 'last_completed_date';
  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';
  static const String _totalQuestionsKey = 'total_questions';
  static const String _testResultsKey = 'test_results_v1';
  static const String _wrongAnswerIdsKey = 'wrong_answer_ids_v1';
  static const String _wrongAnswerPairsKey = 'wrong_answer_pairs_v1';
  static const String _totalXPKey = 'total_xp_v1';
  static const String _unlockedAchievementsKey = 'unlocked_achievements';

  // Constants
  static const int _dailyGoal = 50; // Questions per day
  static const int xpPerCorrectAnswer = 10;
  static const int xpPerQuizComplete = 50;

  /// Stream that emits the unified state
  Stream<UserProgressState> get stateStream => _stateController.stream;

  /// Stream that emits the list of unlocked achievement IDs
  Stream<List<String>> get achievementsStream => _achievementsController.stream;

  /// Stream that emits the number of questions answered today
  Stream<int> get dailyProgressStream => _dailyProgressController.stream;

  /// Stream that emits the current streak count
  Stream<int> get streakStream => _streakController.stream;

  /// Stream that emits the current list of test results
  Stream<List<TestResult>> get resultsStream => _testResultsController.stream;
  
  /// Stream that emits the current XP total
  Stream<int> get xpStream => _xpController.stream;
  
  /// Stream that emits the current Level
  Stream<int> get levelStream => _levelController.stream;

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
  
  /// Get the current total XP
  Future<int> get totalXP async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalXPKey) ?? 0;
  }
  
  /// Calculate level based on XP using simple thresholds
  /// Level 1: 0-99 XP
  /// Level 2: 100-249 XP
  /// Level 3: 250-449 XP
  /// Level 4: 450-699 XP
  /// Level 5: 700-999 XP
  /// Level 6: 1000-1399 XP
  /// Level 7: 1400-1899 XP
  /// Level 8: 1900-2499 XP
  /// Level 9: 2500-3199 XP
  /// Level 10+: 3200+ XP
  int calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 250) return 2;
    if (xp < 450) return 3;
    if (xp < 700) return 4;
    if (xp < 1000) return 5;
    if (xp < 1400) return 6;
    if (xp < 1900) return 7;
    if (xp < 2500) return 8;
    if (xp < 3200) return 9;
    return 10; // Max level
  }
  
  /// Get XP required for next level
  int getXPForNextLevel(int currentLevel) {
    switch (currentLevel) {
      case 1: return 100;
      case 2: return 250;
      case 3: return 450;
      case 4: return 700;
      case 5: return 1000;
      case 6: return 1400;
      case 7: return 1900;
      case 8: return 2500;
      case 9: return 3200;
      default: return 3200; // Max level reached
    }
  }
  
  /// Get XP at start of current level
  int getXPForCurrentLevel(int currentLevel) {
    switch (currentLevel) {
      case 1: return 0;
      case 2: return 100;
      case 3: return 250;
      case 4: return 450;
      case 5: return 700;
      case 6: return 1000;
      case 7: return 1400;
      case 8: return 1900;
      case 9: return 2500;
      case 10: return 3200;
      default: return 0;
    }
  }
  
  /// Initialize the service and load current values
  Future<void> initialize() async {
    if (_isInitialized) return; // Prevent double initialization
    
    try {
      // Load current values
      _currentDailyProgress = await this.dailyProgress;
      _currentStreak = await this.currentStreak;
      _currentXP = await this.totalXP;
      _currentLevel = calculateLevel(_currentXP);
      
      _emitState();
      
      // Load test results and emit to stream
      await _loadTestResults();
      
      _isInitialized = true;
      Logger.info('UserProgressService initialized. State emitted.');

      // Load achievements
      final unlockedAchievements = prefs.getStringList(_unlockedAchievementsKey) ?? [];
      _achievementsController.add(unlockedAchievements);
    } catch (e) {
      Logger.error('Failed to initialize UserProgressService', e);
      _cachedResults = [];
      _testResultsController.add([]);
      _isInitialized = true;
    }
  }

  /// Helper to emit current state to all streams
  void _emitState() {
    // Emit unified state
    _stateController.add(UserProgressState(
      dailyProgress: _currentDailyProgress,
      streak: _currentStreak,
      xp: _currentXP,
      level: _currentLevel,
    ));

    // Emit individual streams (for backward compatibility)
    _dailyProgressController.add(_currentDailyProgress);
    _streakController.add(_currentStreak);
    _xpController.add(_currentXP);
    _levelController.add(_currentLevel);
  }

  /// Add XP and notify listeners if level changes
  Future<void> addXP(int amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentXP = (prefs.getInt(_totalXPKey) ?? 0) + amount;
      
      await prefs.setInt(_totalXPKey, _currentXP);
      
      final oldLevel = _currentLevel;
      _currentLevel = calculateLevel(_currentXP);
      
      _emitState();
      
      if (_currentLevel > oldLevel) {
        Logger.info('Level Up! $oldLevel -> $_currentLevel (XP: $_currentXP)');
      }
      
      Logger.info('Added $amount XP. Total: $_currentXP');
      
      // Check for achievements
      await checkAchievements();
    } catch (e) {
      Logger.error('Failed to add XP', e);
    }
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
      
      // Update cache
      _currentDailyProgress = dailyQuestions;
      _currentStreak = currentStreak;
      
      _emitState();
      
      Logger.info('Question completed. Daily: $dailyQuestions/$_dailyGoal, Streak: $currentStreak');
      
      // Check if daily goal is met
      await _checkDailyGoal();
      
      // Check for achievements
      await checkAchievements();
      
    } catch (e) {
      Logger.error('Failed to complete question', e);
    }
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


  /// Check if service is already initialized
  bool _isInitialized = false;

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Force refresh the test results (useful for manual refresh)
  Future<void> refreshTestResults() async {
    await _loadTestResults();
  }

  /// Check and unlock achievements
  Future<void> checkAchievements() async {
    try {
     // Load current stats
     final streak = await this.currentStreak;
     final xp = await this.totalXP;
     final level = calculateLevel(xp);
     final totalQs = await this.totalQuestions;
     
     final prefs = await SharedPreferences.getInstance();
     final unlocked = prefs.getStringList(_unlockedAchievementsKey) ?? [];
     bool newUnlock = false;
     
     for (final achievement in Achievement.all) {
        if (unlocked.contains(achievement.id)) continue;
        
        bool isUnlocked = false;
        switch (achievement.type) {
           case AchievementType.streak:
             if (streak >= achievement.requirement) isUnlocked = true;
             break;
           case AchievementType.xp:
             if (xp >= achievement.requirement) isUnlocked = true;
             break;
           case AchievementType.level:
             if (level >= achievement.requirement) isUnlocked = true;
             break;
           case AchievementType.questions:
             if (totalQs >= achievement.requirement) isUnlocked = true;
             break;
           default:
             break;
        }
        
        if (isUnlocked) {
           unlocked.add(achievement.id);
           newUnlock = true;
           Logger.info('Achievement Unlocked: ${achievement.title}');
        }
     }
     
     if (newUnlock) {
        await prefs.setStringList(_unlockedAchievementsKey, unlocked);
        _achievementsController.add(unlocked);
     }
    } catch (e) {
      Logger.error('Failed to check achievements', e);
    }
  }

  /// Dispose the service and close streams
  void dispose() {
    _stateController.close();
    _achievementsController.close();
    _dailyProgressController.close();
    _streakController.close();
    _testResultsController.close();
    _xpController.close();
    _levelController.close();
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
/// Immutable state object for user progress
class UserProgressState {
  final int dailyProgress;
  final int streak;
  final int xp;
  final int level;

  const UserProgressState({
    required this.dailyProgress,
    required this.streak,
    required this.xp,
    required this.level,
  });
  
  @override
  String toString() => 'UserProgressState(daily: $dailyProgress, streak: $streak, xp: $xp, level: $level)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgressState &&
        other.dailyProgress == dailyProgress &&
        other.streak == streak &&
        other.xp == xp &&
        other.level == level;
  }
  
  @override
  int get hashCode => Object.hash(dailyProgress, streak, xp, level);
}
