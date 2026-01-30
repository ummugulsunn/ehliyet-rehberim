
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final int xp;
  final int weeklyXp;
  final int monthlyXp;
  final int level;
  final DateTime updatedAt;

  LeaderboardEntry({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.xp,
    this.weeklyXp = 0,
    this.monthlyXp = 0,
    required this.level,
    required this.updatedAt,
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    // If the document doesn't exist, return a default entry (shouldn't happen in query usually)
    if (!doc.exists) {
       return LeaderboardEntry(
         uid: doc.id, 
         displayName: 'Unknown', 
         xp: 0, 
         level: 1, 
         updatedAt: DateTime.now()
       );
    }
    
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      uid: doc.id,
      displayName: data['displayName'] ?? 'Unknown User',
      photoUrl: data['photoUrl'],
      xp: data['xp'] ?? 0,
      weeklyXp: data['weeklyXp'] ?? 0,
      monthlyXp: data['monthlyXp'] ?? 0,
      level: data['level'] ?? 1,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'xp': xp,
      'weeklyXp': weeklyXp,
      'monthlyXp': monthlyXp,
      'level': level,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  LeaderboardEntry copyWith({
    String? uid,
    String? displayName,
    String? photoUrl,
    int? xp,
    int? weeklyXp,
    int? monthlyXp,
    int? level,
    DateTime? updatedAt,
  }) {
    return LeaderboardEntry(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      xp: xp ?? this.xp,
      weeklyXp: weeklyXp ?? this.weeklyXp,
      monthlyXp: monthlyXp ?? this.monthlyXp,
      level: level ?? this.level,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
