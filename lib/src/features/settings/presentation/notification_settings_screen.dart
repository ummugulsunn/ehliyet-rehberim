import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/notification_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Ayarlar yüklenemedi: $e'),
        ),
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Daily Reminder Card
              _buildNotificationCard(
                context: context,
                ref: ref,
                icon: Icons.alarm,
                title: 'Günlük Hatırlatma',
                subtitle: 'Her gün belirlediğiniz saatte çalışma hatırlatıcısı',
                enabled: settings.dailyReminderEnabled,
                time: '${settings.dailyReminderHour.toString().padLeft(2, '0')}:${settings.dailyReminderMinute.toString().padLeft(2, '0')}',
                onToggle: (value) {
                  ref.read(notificationSettingsProvider.notifier)
                      .setDailyReminderEnabled(value);
                },
                onTimeChange: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.dailyReminderHour,
                      minute: settings.dailyReminderMinute,
                    ),
                  );
                  if (time != null) {
                    ref.read(notificationSettingsProvider.notifier)
                        .setDailyReminderTime(time.hour, time.minute);
                  }
                },
                iconColor: AppColors.primary,
              ),

              const SizedBox(height: 16),

              // Streak Warning Card
              _buildNotificationCard(
                context: context,
                ref: ref,
                icon: Icons.local_fire_department,
                title: 'Seri Uyarısı',
                subtitle: 'Bugün çalışmadıysanız seri kaybetme uyarısı',
                enabled: settings.streakWarningEnabled,
                time: '${settings.streakWarningHour.toString().padLeft(2, '0')}:${settings.streakWarningMinute.toString().padLeft(2, '0')}',
                onToggle: (value) {
                  ref.read(notificationSettingsProvider.notifier)
                      .setStreakWarningEnabled(value);
                },
                onTimeChange: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.streakWarningHour,
                      minute: settings.streakWarningMinute,
                    ),
                  );
                  if (time != null) {
                    ref.read(notificationSettingsProvider.notifier)
                        .setStreakWarningTime(time.hour, time.minute);
                  }
                },
                iconColor: AppColors.error,
              ),

              const SizedBox(height: 16),

              // Achievement Notifications Card
              _buildSimpleNotificationCard(
                context: context,
                ref: ref,
                icon: Icons.emoji_events,
                title: 'Başarım Bildirimleri',
                subtitle: 'Yeni başarım kazandığınızda bildirim',
                enabled: settings.achievementNotificationsEnabled,
                onToggle: (value) {
                  ref.read(notificationSettingsProvider.notifier)
                      .setAchievementNotificationsEnabled(value);
                },
                iconColor: AppColors.warning,
              ),

              const SizedBox(height: 16),

              // Goal Completed Notifications Card
              _buildSimpleNotificationCard(
                context: context,
                ref: ref,
                icon: Icons.check_circle,
                title: 'Hedef Tamamlama',
                subtitle: 'Günlük hedefi tamamladığınızda bildirim',
                enabled: settings.goalCompletedNotificationsEnabled,
                onToggle: (value) {
                  ref.read(notificationSettingsProvider.notifier)
                      .setGoalCompletedNotificationsEnabled(value);
                },
                iconColor: AppColors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required String time,
    required Function(bool) onToggle,
    required VoidCallback onTimeChange,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Switch(
              value: enabled,
              onChanged: onToggle,
              activeColor: iconColor,
            ),
          ),
          if (enabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: iconColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Bildirim Saati:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onTimeChange,
                    child: Text(
                      time,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleNotificationCard({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required Function(bool) onToggle,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Switch(
          value: enabled,
          onChanged: onToggle,
          activeColor: iconColor,
        ),
      ),
    );
  }
}
