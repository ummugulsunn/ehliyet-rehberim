import 'package:flutter_test/flutter_test.dart';

/// Streak Logic Tests
/// Tests the business logic for streak calculation without SharedPreferences dependency
void main() {
  group('Streak Logic - Pure Functions', () {
    
    /// Calculate new streak based on last activity date
    int calculateNewStreak({
      required DateTime lastActivity,
      required DateTime now,
      required int currentStreak,
      required int availableFreezes,
    }) {
      final lastDate = DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
      final today = DateTime(now.year, now.month, now.day);
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff == 0) {
        // Same day - no change
        return currentStreak;
      } else if (daysDiff == 1) {
        // Perfect continuation
        return currentStreak + 1;
      } else {
        // Missed days
        final daysMissed = daysDiff - 1;
        if (availableFreezes >= daysMissed) {
          // Streak protected
          return currentStreak + 1;
        } else {
          // Streak broken
          return 1;
        }
      }
    }

    /// Calculate remaining freezes after gap
    int calculateRemainingFreezes({
      required DateTime lastActivity,
      required DateTime now,
      required int availableFreezes,
    }) {
      final lastDate = DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
      final today = DateTime(now.year, now.month, now.day);
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff <= 1) {
        return availableFreezes; // No freeze used
      }
      
      final daysMissed = daysDiff - 1;
      if (availableFreezes >= daysMissed) {
        return availableFreezes - daysMissed;
      } else {
        return availableFreezes; // Streak broken, freezes not consumed
      }
    }

    test('Same day activity does not change streak', () {
      final now = DateTime(2024, 1, 15, 10, 0);
      final lastActivity = DateTime(2024, 1, 15, 8, 0);
      
      expect(calculateNewStreak(
        lastActivity: lastActivity,
        now: now,
        currentStreak: 5,
        availableFreezes: 0,
      ), 5);
    });

    test('Next day activity increments streak', () {
      final now = DateTime(2024, 1, 16, 10, 0);
      final lastActivity = DateTime(2024, 1, 15, 20, 0);
      
      expect(calculateNewStreak(
        lastActivity: lastActivity,
        now: now,
        currentStreak: 5,
        availableFreezes: 0,
      ), 6);
    });

    test('Missing one day with freeze protects streak', () {
      final now = DateTime(2024, 1, 17, 10, 0); // 2 days after last
      final lastActivity = DateTime(2024, 1, 15, 10, 0);
      
      expect(calculateNewStreak(
        lastActivity: lastActivity,
        now: now,
        currentStreak: 5,
        availableFreezes: 1,
      ), 6);
    });

    test('Missing one day without freeze breaks streak', () {
      final now = DateTime(2024, 1, 17, 10, 0);
      final lastActivity = DateTime(2024, 1, 15, 10, 0);
      
      expect(calculateNewStreak(
        lastActivity: lastActivity,
        now: now,
        currentStreak: 5,
        availableFreezes: 0,
      ), 1);
    });

    test('Missing two days with 2 freezes protects streak', () {
      final now = DateTime(2024, 1, 18, 10, 0); // 3 days after last
      final lastActivity = DateTime(2024, 1, 15, 10, 0);
      
      expect(calculateNewStreak(
        lastActivity: lastActivity,
        now: now,
        currentStreak: 10,
        availableFreezes: 2,
      ), 11);
    });

    test('Missing two days with 1 freeze breaks streak', () {
      final now = DateTime(2024, 1, 18, 10, 0);
      final lastActivity = DateTime(2024, 1, 15, 10, 0);
      
      expect(calculateNewStreak(
        lastActivity: lastActivity,
        now: now,
        currentStreak: 10,
        availableFreezes: 1,
      ), 1);
    });

    test('Freeze count decreases correctly', () {
      final now = DateTime(2024, 1, 17, 10, 0);
      final lastActivity = DateTime(2024, 1, 15, 10, 0);
      
      expect(calculateRemainingFreezes(
        lastActivity: lastActivity,
        now: now,
        availableFreezes: 2,
      ), 1);
    });

    test('Freeze count stays same on consecutive day', () {
      final now = DateTime(2024, 1, 16, 10, 0);
      final lastActivity = DateTime(2024, 1, 15, 10, 0);
      
      expect(calculateRemainingFreezes(
        lastActivity: lastActivity,
        now: now,
        availableFreezes: 2,
      ), 2);
    });

    test('First activity starts streak at 1', () {
      // Simulating no previous activity (using very old date)
      final now = DateTime(2024, 1, 15, 10, 0);
      final lastActivity = DateTime(2023, 1, 1, 10, 0); // Very old
      
      final result = calculateNewStreak(
        lastActivity: lastActivity,
        now: now,
        currentStreak: 0,
        availableFreezes: 0,
      );
      
      // Should reset to 1 (new streak)
      expect(result, 1);
    });
  });

  group('XP Freeze Purchase Logic', () {
    
    bool canBuyFreeze(int currentXP, int currentFreezes, int maxFreezes, int price) {
      return currentXP >= price && currentFreezes < maxFreezes;
    }

    test('Can buy freeze with enough XP and under max', () {
      expect(canBuyFreeze(500, 0, 2, 500), true);
      expect(canBuyFreeze(1000, 1, 2, 500), true);
    });

    test('Cannot buy freeze at max capacity', () {
      expect(canBuyFreeze(1000, 2, 2, 500), false);
    });

    test('Cannot buy freeze with insufficient XP', () {
      expect(canBuyFreeze(499, 0, 2, 500), false);
      expect(canBuyFreeze(0, 1, 2, 500), false);
    });
  });
}
