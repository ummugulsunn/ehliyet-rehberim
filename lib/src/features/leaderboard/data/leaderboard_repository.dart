
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/leaderboard_entry.dart';
import '../../../core/utils/logger.dart';

class LeaderboardRepository {
  static final LeaderboardRepository _instance = LeaderboardRepository._internal();
  factory LeaderboardRepository() => _instance;
  LeaderboardRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionPath = 'leaderboard';

  /// Update user score in Firestore
  Future<void> updateUserScore(LeaderboardEntry entry) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(entry.uid)
          .set(entry.toMap(), SetOptions(merge: true));
      // Logger.info('Updated leaderboard score for ${entry.uid}');
    } catch (e) {
      Logger.error('Failed to update leaderboard score', e);
    }
  }

  /// Get top users by All Time XP
  Stream<List<LeaderboardEntry>> getTopUsersAllTime({int limit = 50}) {
    return _firestore
        .collection(_collectionPath)
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(doc))
          .toList();
    });
  }

  /// Get top users by Weekly XP
  Stream<List<LeaderboardEntry>> getTopUsersWeekly({int limit = 50}) {
    return _firestore
        .collection(_collectionPath)
        .orderBy('weeklyXp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(doc))
          .toList();
    });
  }

  /// Get top users by Monthly XP
  Stream<List<LeaderboardEntry>> getTopUsersMonthly({int limit = 50}) {
    return _firestore
        .collection(_collectionPath)
        .orderBy('monthlyXp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(doc))
          .toList();
    });
  }

  /// Get current user's entry
  Future<LeaderboardEntry?> getUserEntry(String uid) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(uid).get();
      if (doc.exists) {
        return LeaderboardEntry.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get user leaderboard entry', e);
      return null;
    }
  }

  /// Populate database with realistic dummy data (Dev only)
  Future<void> populateDummyData() async {
    final List<Map<String, dynamic>> dummyUsers = [
      {'name': 'Ayşe Yılmaz', 'photo': null},
      {'name': 'Mehmet Demir', 'photo': null},
      {'name': 'Fatma Kaya', 'photo': null},
      {'name': 'Ali Çelik', 'photo': null},
      {'name': 'Zeynep Şahin', 'photo': null},
      {'name': 'Yusuf Yıldız', 'photo': null},
      {'name': 'Elif Öztürk', 'photo': null},
      {'name': 'Mustafa Aydın', 'photo': null},
      {'name': 'Hüseyin Arslan', 'photo': null},
      {'name': 'Emine Kara', 'photo': null},
      {'name': 'Murat Koç', 'photo': null},
      {'name': 'Hatice Kurt', 'photo': null},
      {'name': 'İbrahim Özkan', 'photo': null},
      {'name': 'Selin Polat', 'photo': null},
      {'name': 'Burak Can', 'photo': null},
    ];

    final batch = _firestore.batch();
    
    int i = 0;
    for (var u in dummyUsers) {
      i++;
      final uid = 'dummy_user_$i';
      
      // Random generation using system time
      final now = DateTime.now().microsecondsSinceEpoch;
      final xp = 500 + (now % 4500); 
      final weekly = now % 500;
      final monthly = 100 + (now % 1400);
      final level = (xp / 500).ceil();

      final entry = LeaderboardEntry(
        uid: uid,
        displayName: u['name'],
        photoUrl: u['photo'],
        xp: xp,
        weeklyXp: weekly,
        monthlyXp: monthly,
        level: level,
        updatedAt: DateTime.now(),
      );

      final docRef = _firestore.collection(_collectionPath).doc(uid);
      batch.set(docRef, entry.toMap());
    }

    try {
      await batch.commit();
      Logger.info('Successfully populated ${dummyUsers.length} dummy users');
    } catch (e) {
      Logger.error('Failed to populate dummy data', e);
    }
  }
}
