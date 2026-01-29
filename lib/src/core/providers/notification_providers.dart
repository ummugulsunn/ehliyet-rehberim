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
class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettings> {
  static const String _dailyReminderEnabledKey = 'daily_reminder_enabled';
  static const String _dailyReminderHourKey = 'daily_reminder_hour';
  static const String _dailyReminderMinuteKey = 'daily_reminder_minute';
  static const String _streakWarningEnabledKey = 'streak_warning_enabled';
  static const String _streakWarningHourKey = 'streak_warning_hour';
  static const String _streakWarningMinuteKey = 'streak_warning_minute';
  static const String _achievementNotificationsKey = 'achievement_notifications_enabled';
  static const String _goalCompletedNotificationsKey = 'goal_completed_notifications_enabled';

  @override
  Future<NotificationSettings> build() async {
    return await _loadSettings();
  }

  Future<NotificationSettings> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final settings = NotificationSettings(
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
      await _updateNotifications(settings);
      
      return settings;
    } catch (e) {
      Logger.error('Failed to load notification settings', e);
      return const NotificationSettings();
    }
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    final currentState = state.valueOrNull ?? const NotificationSettings();
    final newState = currentState.copyWith(dailyReminderEnabled: enabled);
    state = AsyncValue.data(newState);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderEnabledKey, enabled);
    await _updateNotifications(newState);
  }

  Future<void> setDailyReminderTime(int hour, int minute) async {
    final currentState = state.valueOrNull ?? const NotificationSettings();
    final newState = currentState.copyWith(
      dailyReminderHour: hour,
      dailyReminderMinute: minute,
    );
    state = AsyncValue.data(newState);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyReminderHourKey, hour);
    await prefs.setInt(_dailyReminderMinuteKey, minute);
    await _updateNotifications(newState);
  }

  Future<void> setStreakWarningEnabled(bool enabled) async {
    final currentState = state.valueOrNull ?? const NotificationSettings();
    final newState = currentState.copyWith(streakWarningEnabled: enabled);
    state = AsyncValue.data(newState);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_streakWarningEnabledKey, enabled);
    await _updateNotifications(newState);
  }

  Future<void> setStreakWarningTime(int hour, int minute) async {
    final currentState = state.valueOrNull ?? const NotificationSettings();
    final newState = currentState.copyWith(
      streakWarningHour: hour,
      streakWarningMinute: minute,
    );
    state = AsyncValue.data(newState);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakWarningHourKey, hour);
    await prefs.setInt(_streakWarningMinuteKey, minute);
    await _updateNotifications(newState);
  }

  Future<void> setAchievementNotificationsEnabled(bool enabled) async {
    final currentState = state.valueOrNull ?? const NotificationSettings();
    final newState = currentState.copyWith(achievementNotificationsEnabled: enabled);
    state = AsyncValue.data(newState);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_achievementNotificationsKey, enabled);
  }

  Future<void> setGoalCompletedNotificationsEnabled(bool enabled) async {
    final currentState = state.valueOrNull ?? const NotificationSettings();
    final newState = currentState.copyWith(goalCompletedNotificationsEnabled: enabled);
    state = AsyncValue.data(newState);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_goalCompletedNotificationsKey, enabled);
  }

  Future<void> _updateNotifications(NotificationSettings settings) async {
    // Disabled due to build issues
    /*
    final notificationService = NotificationService(); // Was .instance

    // Cancel all existing notifications
    await notificationService.cancelAll();

    // Schedule daily reminder if enabled
    if (settings.dailyReminderEnabled) {
      await notificationService.scheduleDailyReminder(
        hour: settings.dailyReminderHour,
        minute: settings.dailyReminderMinute,
      );
    }

    // Schedule streak warning if enabled
    if (settings.streakWarningEnabled) {
      await notificationService.scheduleStreakWarning(
        hour: settings.streakWarningHour,
        minute: settings.streakWarningMinute,
      );
    }
    */
  }
}

/// Provider for notification settings
final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
