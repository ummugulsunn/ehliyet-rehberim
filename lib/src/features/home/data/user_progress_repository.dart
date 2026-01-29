import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/logger.dart';
import '../../quiz/domain/test_result_model.dart';
import '../../home/domain/achievement_model.dart';

class _SRSItem {
  final String examId;
  final int questionId;
  final int level;
  final DateTime nextReview;

  _SRSItem({
    required this.examId,
    required this.questionId,
    required this.level,
    required this.nextReview,
  });
}

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
  int _currentStreakFreezes = 0;

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
  static const String _streakFreezesKey = 'streak_freezes';

  // Constants
  static const int _dailyGoal = 50; // Questions per day
  static const int xpPerCorrectAnswer = 10;
  static const int xpPerQuizComplete = 50;
  static const int streakFreezePrice = 500;
  static const int maxStreakFreezes = 2;

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

  /// Get current streak freezes count
  Future<int> get streakFreezes async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakFreezesKey) ?? 0;
  }

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
      _currentStreakFreezes = await this.streakFreezes;
      
      _emitState();
      
      // Load test results and emit to stream
      await _loadTestResults();
      
      _isInitialized = true;
      Logger.info('UserProgressService initialized. State emitted.');

      // Load achievements
      final prefs = await SharedPreferences.getInstance();
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
      streakFreezes: _currentStreakFreezes,
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

  /// Purchase a streak freeze using XP
  Future<bool> buyStreakFreeze() async {
    try {
      if (_currentStreakFreezes >= maxStreakFreezes) {
        Logger.info('Max streak freezes reached');
        return false;
      }

      if (_currentXP < streakFreezePrice) {
        Logger.info('Not enough XP to buy streak freeze');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      
      // Deduct XP
      _currentXP -= streakFreezePrice;
      await prefs.setInt(_totalXPKey, _currentXP);
      
      // Add Freeze
      _currentStreakFreezes++;
      await prefs.setInt(_streakFreezesKey, _currentStreakFreezes);
      
      _emitState();
      Logger.info('Bought streak freeze. XP: $_currentXP, Freezes: $_currentStreakFreezes');
      return true;
    } catch (e) {
      Logger.error('Failed to buy streak freeze', e);
      return false;
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
      int freezes = prefs.getInt(_streakFreezesKey) ?? 0;
      
      // Check if it's a new day
      if (lastCompletedDate != today) {
        // Check gap since last activity
        if (lastCompletedDate != null) {
          final lastDate = DateTime.parse(lastCompletedDate);
          final now = DateTime.now();
          // Calculate difference in days, ignoring time
          final lastDateStart = DateTime(lastDate.year, lastDate.month, lastDate.day);
          final todayStart = DateTime(now.year, now.month, now.day);
          final difference = todayStart.difference(lastDateStart).inDays;
          
          if (difference == 1) {
            // Continued perfectly (yesterday)
            currentStreak++;
          } else if (difference > 1) {
            // Missed one or more days
            int daysMissed = difference - 1;
            
            if (freezes >= daysMissed) {
              // Streak Protected!
              freezes -= daysMissed;
              await prefs.setInt(_streakFreezesKey, freezes);
              _currentStreakFreezes = freezes;
              currentStreak++; // Continue streak
              Logger.info('Streak preserved using $daysMissed freeze(s)!');
            } else {
              // Streak Broken
              currentStreak = 1;
              Logger.info('Streak broken. Missed $daysMissed days, only had $freezes freezes.');
            }
          } else {
             // Should not happen if lastCompletedDate != today, unless clock changed backwards
             // Treat as same streak or ignore
             // currentStreak = currentStreak;
          }
        } else {
           // First ever activity
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
      await prefs.remove(_wrongAnswerSRSKey); // Also clear SRS
      Logger.info('Cleared all wrong answer pairs and SRS data');
    } catch (e) {
      Logger.error('Failed to clear wrong answer pairs', e);
    }
  }

  // ================================
  // Spaced Repetition System (SRS)
  // ================================
  static const String _wrongAnswerSRSKey = 'wrong_answer_srs_v1';

  /// Add or Update SRS Status for a question
  /// If wrong -> Reset level to 0, immediate review
  /// If correct -> Increase level, schedule future review
  Future<void> updateSRSStatus({
    required String examId, 
    required int questionId, 
    required bool isCorrect
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(_wrongAnswerSRSKey) ?? [];
      
      // Decode existing SRS items
      // Format: "examId:questionId:level:nextReviewEpoch"
      final Map<String, _SRSItem> items = {};
      for (var s in rawList) {
        final parts = s.split(':');
        if (parts.length == 4) {
          final key = '${parts[0]}:${parts[1]}';
          items[key] = _SRSItem(
            examId: parts[0],
            questionId: int.parse(parts[1]),
            level: int.parse(parts[2]),
            nextReview: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[3])),
          );
        }
      }

      final key = '$examId:$questionId';
      final currentItem = items[key];

      if (!isCorrect) {
        // User answered WRONG (or added for first time)
        // Reset/Init to Level 0, Due Now
        items[key] = _SRSItem(
          examId: examId,
          questionId: questionId,
          level: 0,
          nextReview: DateTime.now(), // Due immediately
        );
      } else {
        // User answered CORRECT
        if (currentItem != null) {
          final newLevel = currentItem.level + 1;
          
          if (newLevel > 4) {
             // Graduated! Remove from SRS loop
             items.remove(key);
          } else {
             // Schedule next review
             // Intervals: 0->1d, 1->3d, 2->7d, 3->14d, 4->30d
             int daysToAdd = 1;
             if (newLevel == 1) daysToAdd = 3;
             if (newLevel == 2) daysToAdd = 7;
             if (newLevel == 3) daysToAdd = 14;
             if (newLevel == 4) daysToAdd = 30;
             
             items[key] = _SRSItem(
               examId: examId,
               questionId: questionId,
               level: newLevel,
               nextReview: DateTime.now().add(Duration(days: daysToAdd)),
             );
          }
        }
        // If correct but not in SRS, ignore (shouldn't happen in wrong answers mode)
      }

      // Save back
      final List<String> newRawList = items.values.map((i) => 
        '${i.examId}:${i.questionId}:${i.level}:${i.nextReview.millisecondsSinceEpoch}'
      ).toList();
      
      await prefs.setStringList(_wrongAnswerSRSKey, newRawList);
      
      // Also sync to legacy simple pair list for backward compatibility/check checks
      // If in items map -> ensure in pairs list
      // If removed from map -> remove from pairs list
      final Set<String> activeKeys = items.keys.toSet();
      final legacyList = prefs.getStringList(_wrongAnswerPairsKey) ?? [];
      final legacySet = legacyList.toSet();
      
      // Add new
      for (var k in activeKeys) {
        if (!legacySet.contains(k)) legacySet.add(k);
      }
      
      // Remove graduated
      // Actually, be careful. SRS items map only contains "active" wrong answers.
      // If we graduated (removed from items), we should also remove from legacy list.
      // But legacy list usually tracked "ever wrong". 
      // Let's assume strict sync: If it's not in SRS, it's not "Wrong" anymore.
      // Wait, complex case: existing users have legacy list but no SRS data.
      // We will handle migration in `getDueSRSItems`.
      
      // For now, simpler sync: remove ONLY specific key if graduated
      if (isCorrect && !items.containsKey(key)) {
        if (legacySet.contains(key)) legacySet.remove(key);
      } else if (!isCorrect) {
        if (!legacySet.contains(key)) legacySet.add(key);
      }
      
      await prefs.setStringList(_wrongAnswerPairsKey, legacySet.toList());

    } catch (e) {
      Logger.error('Failed to update SRS', e);
    }
  }
  
  /// Get all items due for review (or new ones migrated)
  /// Returns List of "examId:questionId" strings
  Future<List<String>> getDueSRSItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Check/Migrate Legacy Data
      final legacyPairs = prefs.getStringList(_wrongAnswerPairsKey) ?? [];
      List<String> srsList = prefs.getStringList(_wrongAnswerSRSKey) ?? [];
      
      final Map<String, _SRSItem> srsMap = {};
      
      // Parse SRS
      for (var s in srsList) {
         final parts = s.split(':');
         if (parts.length == 4) {
           final key = '${parts[0]}:${parts[1]}';
           srsMap[key] = _SRSItem(
             examId: parts[0],
             questionId: int.parse(parts[1]),
             level: int.parse(parts[2]),
             nextReview: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[3])),
           );
         }
      }
      
      // Sync: If in legacy but not in SRS, add as Level 0 (Due Now)
      bool changed = false;
      for (var pair in legacyPairs) {
        if (!srsMap.containsKey(pair)) {
           final parts = pair.split(':');
           if (parts.length == 2) {
             srsMap[pair] = _SRSItem(
               examId: parts[0],
               questionId: int.parse(parts[1]),
               level: 0,
               nextReview: DateTime.now(),
             );
             changed = true;
           }
        }
      }
      
      if (changed) {
         // Save updated SRS
         final newList = srsMap.values.map((i) => 
           '${i.examId}:${i.questionId}:${i.level}:${i.nextReview.millisecondsSinceEpoch}'
         ).toList();
         await prefs.setStringList(_wrongAnswerSRSKey, newList);
      }
      
      // 2. Filter Due Items
      final now = DateTime.now();
      final List<String> duePairs = [];
      
      for (var item in srsMap.values) {
        if (item.nextReview.isBefore(now)) {
           duePairs.add('${item.examId}:${item.questionId}');
        }
      }
      
      return duePairs;
    } catch (e) {
      Logger.error('Failed to get SRS items', e);
      return [];
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
         final List<String> toSave = unlocked.toSet().toList(); // Ensure unique
         await prefs.setStringList(_unlockedAchievementsKey, toSave);
         _achievementsController.add(toSave);
      }
    } catch (e) {
      Logger.error('Failed to check achievements', e);
    }
  }

  /// Get the list of unlocked achievements directly
  Future<List<String>> getUnlockedAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_unlockedAchievementsKey) ?? [];
    } catch (e) {
      Logger.error('Failed to get unlocked achievements', e);
      return [];
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
  /// Get statistics by category (Accuracy %)
  /// Returns a map of Category Name -> Accuracy (0.0 - 1.0)
  Map<String, double> getCategoryStats() {
    final results = getAllTestResults();
    if (results.isEmpty) return {};

    final Map<String, List<TestResult>> byCategory = {};
    for (final result in results) {
      // Normalize category names if needed, or keep as is
      final cat = result.category;
      if (cat == 'Genel' || cat == 'Yanlışlarım' || cat == 'Deneme Sınavı') continue; // Skip generic exams
      (byCategory[cat] ??= []).add(result);
    }

    final Map<String, double> stats = {};
    byCategory.forEach((cat, list) {
      if (list.isEmpty) return;
      int totalCorrect = 0;
      int totalQuestions = 0;
      for (final r in list) {
        totalCorrect += r.correctAnswers;
        totalQuestions += r.totalQuestions;
      }
      if (totalQuestions > 0) {
        stats[cat] = totalCorrect / totalQuestions;
      } else {
        stats[cat] = 0.0;
      }
    });

    return stats;
  }

  /// Get weakest categories (sorted by accuracy ascending)
  List<String> getWeakestCategories({int limit = 3}) {
    final stats = getCategoryStats();
    if (stats.isEmpty) return [];

    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    return sortedEntries.take(limit).map((e) => e.key).toList();
  }

  /// Calculate Exam Readiness Score (0-100)
  /// Returns -1 if insufficient data (< 5 tests)
  int calculateReadinessScore() {
    final results = getAllTestResults();
    // Filter out "Yanlışlarım" or very short tests if necessary
    final validResults = results.where((r) => r.category != 'Yanlışlarım' && r.totalQuestions >= 10).toList();
    
    if (validResults.length < 5) return -1;

    // Sort by date descending (newest first)
    validResults.sort((a, b) => b.date.compareTo(a.date));
    
    // Take last 15 instead of 10 to have more data points if available
    final recentResults = validResults.take(15).toList();
    
    double totalWeightedScore = 0;
    double totalWeight = 0;
    
    for (int i = 0; i < recentResults.length; i++) {
      final result = recentResults[i];
      final score = (result.correctAnswers / result.totalQuestions) * 100;
      
      // Base weight: Newest (index 0) gets 1.0, decreasing by 0.05
      double weight = 1.0 - (i * 0.05);
      if (weight < 0.4) weight = 0.4; // Minimum recency weight
      
      // Bonus weight for EXAM simulations (1.5x)
      if (result.isExamMode) {
        weight *= 1.5;
      }
      
      totalWeightedScore += score * weight;
      totalWeight += weight;
    }
    
    if (totalWeight == 0) return 0;
    
    return (totalWeightedScore / totalWeight).round().clamp(0, 100);
  }
} 
/// Immutable state object for user progress
class UserProgressState {
  final int dailyProgress;
  final int streak;
  final int xp;
  final int level;
  final int streakFreezes;

  const UserProgressState({
    required this.dailyProgress,
    required this.streak,
    required this.xp,
    required this.level,
    this.streakFreezes = 0,
  });
  
  @override
  String toString() => 'UserProgressState(daily: $dailyProgress, streak: $streak, xp: $xp, level: $level, freezes: $streakFreezes)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgressState &&
        other.dailyProgress == dailyProgress &&
        other.streak == streak &&
        other.xp == xp &&
        other.level == level &&
        other.streakFreezes == streakFreezes;
  }
  
  @override
  int get hashCode => Object.hash(dailyProgress, streak, xp, level, streakFreezes);
}
