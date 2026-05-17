import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification service - handles all local notifications for the app
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification service - call once in main()
  static Future<void> initialize() async {
    // Skip on web - notifications not supported
    if (kIsWeb) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  /// Show an instant notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'student_planner_channel',
        'Student Planner',
        channelDescription: 'Smart Student Planner notifications',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, details);
  }

  /// Show study reminder notification
  static Future<void> showStudyReminder(String subject) async {
    await showNotification(
      id: 1,
      title: '📚 Study Time!',
      body: 'Time to study $subject. Stay focused! 💪',
    );
  }

  /// Show task deadline notification
  static Future<void> showTaskReminder(String taskTitle) async {
    await showNotification(
      id: 2,
      title: '⚠️ Task Due Soon!',
      body: '$taskTitle is due soon. Don\'t forget to complete it!',
    );
  }

  /// Show attendance warning notification
  static Future<void> showAttendanceWarning(String subject) async {
    await showNotification(
      id: 3,
      title: '🚨 Attendance Warning!',
      body: 'Your attendance in $subject is below 75%!',
    );
  }

  /// Show pomodoro complete notification
  static Future<void> showPomodoroComplete(bool isBreak) async {
    await showNotification(
      id: 4,
      title: isBreak ? '✅ Break Over!' : '🎉 Session Complete!',
      body: isBreak
          ? 'Break is over. Time to focus again! 🔥'
          : 'Great work! Take a short break. ☕',
    );
  }
}