import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

/// Notification settings state
class NotificationSettings {
  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final bool streakWarningEnabled;
  final int streakWarningHour;
  final int streakWarningMinute;
  final bool achievementNotificationsEnabled;
  final bool goalCompletedNotificationsEnabled;

  const NotificationSettings({
    this.dailyReminderEnabled = true,
    this.dailyReminderHour = 20, // 8 PM default
    this.dailyReminderMinute = 0,
    this.streakWarningEnabled = true,
    this.streakWarningHour = 21, // 9 PM default
    this.streakWarningMinute = 0,
    this.achievementNotificationsEnabled = true,
    this.goalCompletedNotificationsEnabled = true,
  });

  NotificationSettings copyWith({
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    bool? streakWarningEnabled,
    int? streakWarningHour,
    int? streakWarningMinute,
    bool? achievementNotificationsEnabled,
    bool? goalCompletedNotificationsEnabled,
  }) {
    return NotificationSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      streakWarningEnabled: streakWarningEnabled ?? this.streakWarningEnabled,
      streakWarningHour: streakWarningHour ?? this.streakWarningHour,
      streakWarningMinute: streakWarningMinute ?? this.streakWarningMinute,
      achievementNotificationsEnabled:
          achievementNotificationsEnabled ?? this.achievementNotificationsEnabled,
      goalCompletedNotificationsEnabled:
          goalCompletedNotificationsEnabled ?? this.goalCompletedNotificationsEnabled,
    );
  }
}

/// Notification settings provider
class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  static const String _dailyReminderEnabledKey = 'daily_reminder_enabled';
  static const String _dailyReminderHourKey = 'daily_reminder_hour';
  static const String _dailyReminderMinuteKey = 'daily_reminder_minute';
  static const String _streakWarningEnabledKey = 'streak_warning_enabled';
  static const String _streakWarningHourKey = 'streak_warning_hour';
  static const String _streakWarningMinuteKey = 'streak_warning_minute';
  static const String _achievementNotificationsKey = 'achievement_notifications_enabled';
  static const String _goalCompletedNotificationsKey = 'goal_completed_notifications_enabled';

  @override
  NotificationSettings build() {
    _loadSettings();
    return const NotificationSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      state = NotificationSettings(
        dailyReminderEnabled: prefs.getBool(_dailyReminderEnabledKey) ?? true,
        dailyReminderHour: prefs.getInt(_dailyReminderHourKey) ?? 20,
        dailyReminderMinute: prefs.getInt(_dailyReminderMinuteKey) ?? 0,
        streakWarningEnabled: prefs.getBool(_streakWarningEnabledKey) ?? true,
        streakWarningHour: prefs.getInt(_streakWarningHourKey) ?? 21,
        streakWarningMinute: prefs.getInt(_streakWarningMinuteKey) ?? 0,
        achievementNotificationsEnabled: prefs.getBool(_achievementNotificationsKey) ?? true,
        goalCompletedNotificationsEnabled: prefs.getBool(_goalCompletedNotificationsKey) ?? true,
      );

      // Schedule notifications based on settings
      await _updateNotifications();
    } catch (e) {
      Logger.error('Failed to load notification settings', e);
    }
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderEnabledKey, enabled);
    state = state.copyWith(dailyReminderEnabled: enabled);
    await _updateNotifications();
  }

  Future<void> setDailyReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyReminderHourKey, hour);
    await prefs.setInt(_dailyReminderMinuteKey, minute);
    state = state.copyWith(
      dailyReminderHour: hour,
      dailyReminderMinute: minute,
    );
    await _updateNotifications();
  }

  Future<void> setStreakWarningEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_streakWarningEnabledKey, enabled);
    state = state.copyWith(streakWarningEnabled: enabled);
    await _updateNotifications();
  }

  Future<void> setStreakWarningTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakWarningHourKey, hour);
    await prefs.setInt(_streakWarningMinuteKey, minute);
    state = state.copyWith(
      streakWarningHour: hour,
      streakWarningMinute: minute,
    );
    await _updateNotifications();
  }

  Future<void> setAchievementNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_achievementNotificationsKey, enabled);
    state = state.copyWith(achievementNotificationsEnabled: enabled);
  }

  Future<void> setGoalCompletedNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_goalCompletedNotificationsKey, enabled);
    state = state.copyWith(goalCompletedNotificationsEnabled: enabled);
  }

  Future<void> _updateNotifications() async {
    final notificationService = NotificationService.instance;

    // Cancel all existing notifications
    await notificationService.cancelAll();

    // Schedule daily reminder if enabled
    if (state.dailyReminderEnabled) {
      await notificationService.scheduleDailyReminder(
        hour: state.dailyReminderHour,
        minute: state.dailyReminderMinute,
      );
    }

    // Schedule streak warning if enabled
    if (state.streakWarningEnabled) {
      await notificationService.scheduleStreakWarning(
        hour: state.streakWarningHour,
        minute: state.streakWarningMinute,
      );
    }
  }
}

/// Provider for notification settings
final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
