import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dummy implementation to bypass build errors
class NotificationService {
  Future<void> init() async {
    // print('NotificationService: init (disabled)');
  }

  Future<void> showDailyReminder() async {
     // print('NotificationService: showDailyReminder (disabled)');
  }

  Future<void> cancelAll() async {
     // print('NotificationService: cancelAll (disabled)');
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
