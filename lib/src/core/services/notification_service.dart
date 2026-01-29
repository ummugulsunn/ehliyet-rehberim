import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/logger.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._internal();

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      Logger.info('NotificationService initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize NotificationService', e);
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    Logger.info('Notification tapped: ${response.payload}');
    // Handle navigation based on payload if needed
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    final result = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true; // Android doesn't need runtime permission
  }

  /// Schedule daily study reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      await _notifications.zonedSchedule(
        0, // Notification ID
        'Günlük Çalışma Zamanı! 📚',
        'Bugünkü hedefini tamamlamak için test çözmeye başla!',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Günlük Hatırlatma',
            channelDescription: 'Günlük çalışma hatırlatıcıları',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      Logger.info('Daily reminder scheduled for $hour:$minute');
    } catch (e) {
      Logger.error('Failed to schedule daily reminder', e);
    }
  }

  /// Schedule streak warning (when user hasn't studied today)
  Future<void> scheduleStreakWarning({
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      await _notifications.zonedSchedule(
        1, // Notification ID
        'Serini Kaybetme! 🔥',
        'Bugün hiç test çözmedin. Serini korumak için hemen başla!',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_warning',
            'Seri Uyarısı',
            channelDescription: 'Seri kaybetme uyarıları',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      Logger.info('Streak warning scheduled for $hour:$minute');
    } catch (e) {
      Logger.error('Failed to schedule streak warning', e);
    }
  }

  /// Show achievement notification
  Future<void> showAchievementNotification({
    required String title,
    required String description,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000, // Unique ID
        title,
        description,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'achievements',
            'Başarımlar',
            channelDescription: 'Başarım bildirimleri',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      Logger.info('Achievement notification shown: $title');
    } catch (e) {
      Logger.error('Failed to show achievement notification', e);
    }
  }

  /// Show goal completed notification
  Future<void> showGoalCompletedNotification() async {
    if (!_isInitialized) await initialize();

    try {
      await _notifications.show(
        2, // Notification ID
        'Günlük Hedef Tamamlandı! 🎉',
        'Harika! Bugünkü hedefini tamamladın. Yarın görüşmek üzere!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'goal_completed',
            'Hedef Tamamlandı',
            channelDescription: 'Günlük hedef tamamlama bildirimleri',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      Logger.info('Goal completed notification shown');
    } catch (e) {
      Logger.error('Failed to show goal completed notification', e);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    if (!_isInitialized) await initialize();
    await _notifications.cancelAll();
    Logger.info('All notifications cancelled');
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    if (!_isInitialized) await initialize();
    await _notifications.cancel(id);
    Logger.info('Notification $id cancelled');
  }

  /// Get next instance of specified time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) await initialize();

    final result = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    return result ?? true;
  }
}
