import 'package:ehliyet_rehberim/src/features/home/data/user_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProgressRepository - Level Calculation', () {
    late UserProgressRepository repository;

    setUp(() {
      repository = UserProgressRepository();
    });

    test('calculateLevel returns 1 for XP < 100', () {
      expect(repository.calculateLevel(0), 1);
      expect(repository.calculateLevel(50), 1);
      expect(repository.calculateLevel(99), 1);
    });

    test('calculateLevel returns 2 for XP 100-249', () {
      expect(repository.calculateLevel(100), 2);
      expect(repository.calculateLevel(200), 2);
      expect(repository.calculateLevel(249), 2);
    });

    test('calculateLevel returns 3 for XP 250-449', () {
      expect(repository.calculateLevel(250), 3);
      expect(repository.calculateLevel(350), 3);
      expect(repository.calculateLevel(449), 3);
    });

    test('calculateLevel returns correct levels for higher XP', () {
      expect(repository.calculateLevel(450), 4);
      expect(repository.calculateLevel(700), 5);
      expect(repository.calculateLevel(1000), 6);
      expect(repository.calculateLevel(1400), 7);
      expect(repository.calculateLevel(1900), 8);
      expect(repository.calculateLevel(2500), 9);
      expect(repository.calculateLevel(3200), 10);
      expect(repository.calculateLevel(10000), 10); // Max level
    });
  });

  group('UserProgressRepository - XP Thresholds', () {
    late UserProgressRepository repository;

    setUp(() {
      repository = UserProgressRepository();
    });

    test('getXPForNextLevel returns correct thresholds', () {
      expect(repository.getXPForNextLevel(1), 100);
      expect(repository.getXPForNextLevel(2), 250);
      expect(repository.getXPForNextLevel(3), 450);
      expect(repository.getXPForNextLevel(4), 700);
      expect(repository.getXPForNextLevel(5), 1000);
      expect(repository.getXPForNextLevel(6), 1400);
      expect(repository.getXPForNextLevel(7), 1900);
      expect(repository.getXPForNextLevel(8), 2500);
      expect(repository.getXPForNextLevel(9), 3200);
      expect(repository.getXPForNextLevel(10), 3200); // Max
    });

    test('getXPForCurrentLevel returns correct base XP', () {
      expect(repository.getXPForCurrentLevel(1), 0);
      expect(repository.getXPForCurrentLevel(2), 100);
      expect(repository.getXPForCurrentLevel(3), 250);
      expect(repository.getXPForCurrentLevel(5), 700);
      expect(repository.getXPForCurrentLevel(10), 3200);
    });

    test('XP progress calculation is correct', () {
      final xp = 150; // Level 2, 50 XP into the level
      final level = repository.calculateLevel(xp);
      final currentBase = repository.getXPForCurrentLevel(level);
      final nextBase = repository.getXPForNextLevel(level);
      final range = nextBase - currentBase; // 250 - 100 = 150
      final progress = (xp - currentBase) / range; // (150 - 100) / 150 = 0.333

      expect(level, 2);
      expect(progress, closeTo(0.333, 0.01));
    });
  });

  group('UserProgressRepository - Constants', () {
    test('XP constants are correctly defined', () {
      expect(UserProgressRepository.xpPerCorrectAnswer, 10);
      expect(UserProgressRepository.xpPerQuizComplete, 50);
      expect(UserProgressRepository.streakFreezePrice, 500);
      expect(UserProgressRepository.maxStreakFreezes, 2);
    });
  });
}
