
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

final topUsersAllTimeProvider = StreamProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.watch(leaderboardRepositoryProvider).getTopUsersAllTime();
});

final topUsersWeeklyProvider = StreamProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.watch(leaderboardRepositoryProvider).getTopUsersWeekly();
});

final topUsersMonthlyProvider = StreamProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.watch(leaderboardRepositoryProvider).getTopUsersMonthly();
});
