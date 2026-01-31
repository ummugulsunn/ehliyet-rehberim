import 'package:flutter/material.dart';

enum AchievementType { streak, xp, level, questions, perfectScore }

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData iconData;
  final AchievementType type;
  final int requirement;
  final bool isSecret;

  // UI helper props
  final Color color;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.type,
    required this.requirement,
    this.isSecret = false,
    this.color = Colors.amber,
  });

  // Predefined achievements
  static const List<Achievement> all = [
    // Streak Achievements
    Achievement(
      id: 'streak_3',
      title: 'İstikrarlı Başlangıç',
      description: '3 gün üst üste test çöz',
      iconData: Icons.local_fire_department,
      type: AchievementType.streak,
      requirement: 3,
      color: Colors.orange,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Haftalık Seri',
      description: '7 gün üst üste test çöz',
      iconData: Icons.whatshot,
      type: AchievementType.streak,
      requirement: 7,
      color: Colors.deepOrange,
    ),

    // Level Achievements
    Achievement(
      id: 'level_5',
      title: 'Şehir İçi Uzmanı',
      description: '5. seviyeye ulaş',
      iconData: Icons.directions_car,
      type: AchievementType.level,
      requirement: 5,
      color: Colors.blue,
    ),
    Achievement(
      id: 'level_10',
      title: 'Otoyol Faresi',
      description: '10. seviyeye ulaş',
      iconData: Icons.speed,
      type: AchievementType.level,
      requirement: 10,
      color: Colors.indigo,
    ),

    // Questions Achievements
    Achievement(
      id: 'questions_100',
      title: 'Çaylak Sürücü',
      description: 'Toplam 100 soru çöz',
      iconData: Icons.checklist,
      type: AchievementType.questions,
      requirement: 100,
      color: Colors.green,
    ),
    Achievement(
      id: 'questions_500',
      title: 'Tecrübeli Sürücü',
      description: 'Toplam 500 soru çöz',
      iconData: Icons.check_circle,
      type: AchievementType.questions,
      requirement: 500,
      color: Colors.teal,
    ),
  ];
}
