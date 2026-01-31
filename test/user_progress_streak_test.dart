
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ehliyet_rehberim/src/features/home/data/user_progress_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  group('UserProgressRepository Streak Logic', () {
    late UserProgressRepository repository;

    // Helper to setup repository with specific initial state
    Future<void> setupRepo({
      required String lastDate, 
      required int currentStreak, 
      int freezes = 0,
    }) async {
      SharedPreferences.setMockInitialValues({
        'last_completed_date': lastDate,
        'current_streak': currentStreak,
        'streak_freezes': freezes,
        'daily_questions': 0,
      });
      // Force new instance to read mock values
      repository = UserProgressRepository(); 
      // We don't call initialize() because it does extra heavy lifting (leaderboards etc)
      // We just want to test completeQuestion which reads/writes directly to Prefs mostly.
      // Actually completeQuestion() does `await SharedPreferences.getInstance()`, so it works.
    }

    test('Case 1: Consecutive Day (Yesterday -> Today) should INCREMENT streak', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      
      await setupRepo(
        lastDate: formatDate(yesterday),
        currentStreak: 5,
        freezes: 0
      );

      await repository.completeQuestion();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('current_streak'), 6, reason: "Streak should increment from 5 to 6");
      expect(prefs.getString('last_completed_date'), formatDate(DateTime.now()), reason: "Date should update to today");
    });

    test('Case 2: Same Day (Today -> Today) should MAINTAIN streak', () async {
      final today = DateTime.now();
      
      await setupRepo(
        lastDate: formatDate(today),
        currentStreak: 5,
        freezes: 0
      );

      await repository.completeQuestion();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('current_streak'), 5, reason: "Streak should remain 5");
    });

    test('Case 3: Missed Day (2 Days Ago -> Today) WITHOUT Freeze should RESET streak', () async {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      
      await setupRepo(
        lastDate: formatDate(twoDaysAgo),
        currentStreak: 10,
        freezes: 0
      );

      await repository.completeQuestion();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('current_streak'), 1, reason: "Streak should reset to 1 (current day active)");
    });

    test('Case 4: Missed Day (2 Days Ago -> Today) WITH Freeze should PRESERVE streak', () async {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      // Difference is 2 days. Gap is 1 day. 
      // Logic: if (freezes >= daysMissed) -> daysMissed = difference - 1 = 1.
      
      await setupRepo(
        lastDate: formatDate(twoDaysAgo),
        currentStreak: 10,
        freezes: 1
      );

      await repository.completeQuestion();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('current_streak'), 11, reason: "Streak should increment (preserved)");
      expect(prefs.getInt('streak_freezes'), 0, reason: "Freeze should be consumed");
    });

    test('Case 5: Missed 2 Days (3 Days Ago -> Today) WITH 1 Freeze should RESET streak', () async {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      // Difference is 3 days. Gap is 2 days. 
      // freezes = 1. Gap = 2. 1 < 2 -> Fail.
      
      await setupRepo(
        lastDate: formatDate(threeDaysAgo),
        currentStreak: 20,
        freezes: 1
      );

      await repository.completeQuestion();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('current_streak'), 1, reason: "Streak should reset because not enough freezes");
      expect(prefs.getInt('streak_freezes'), 1, reason: "Freeze should NOT be consumed if streak breaks");
    });
  });
}
