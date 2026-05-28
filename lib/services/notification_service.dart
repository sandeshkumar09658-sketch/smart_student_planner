import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config.dart';
import 'deadline_service.dart';

/// Notification service - handles all local notifications and sounds for the app
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Initialize notification service - call once in main()
  static Future<void> initialize() async {
    if (kIsWeb) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
  }

  /// Play a sound from assets
  static Future<void> playSound(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (_) {}
  }

  /// Show an instant notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? soundAsset,
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

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );

    if (soundAsset != null) {
      playSound(soundAsset);
    }
  }

  /// Show study reminder notification
  static Future<void> showStudyReminder(String subject) async {
    await showNotification(
      id: AppConfig.notifIdStudyReminder,
      title: 'Study Time!',
      body: 'Time to study $subject. Stay focused!',
      soundAsset: 'sounds/notification.wav',
    );
  }

  /// Show task deadline notification
  static Future<void> showTaskReminder(String taskTitle) async {
    await showNotification(
      id: AppConfig.notifIdTaskReminder,
      title: 'Task Due Soon!',
      body: '$taskTitle is due soon. Don\'t forget to complete it!',
      soundAsset: 'sounds/alarm.wav',
    );
  }

  /// Show urgent deadline notification (within 24h)
  static Future<void> showUrgentDeadline(
      String taskTitle, String detail) async {
    await showNotification(
      id: AppConfig.notifIdDeadlineUrgent,
      title: 'Deadline Approaching!',
      body: '$taskTitle - $detail',
      soundAsset: 'sounds/alarm.wav',
    );
  }

  /// Show attendance warning notification
  static Future<void> showAttendanceWarning(String subject) async {
    await showNotification(
      id: AppConfig.notifIdAttendanceWarning,
      title: 'Attendance Warning!',
      body: 'Your attendance in $subject is below 75%!',
      soundAsset: 'sounds/notification.wav',
    );
  }

  /// Show pomodoro complete notification
  static Future<void> showPomodoroComplete(bool isBreak) async {
    await showNotification(
      id: AppConfig.notifIdPomodoroComplete,
      title: isBreak ? 'Break Over!' : 'Session Complete!',
      body: isBreak
          ? 'Break is over. Time to focus again!'
          : 'Great work! Take a short break.',
      soundAsset: 'sounds/bell.wav',
    );
  }

  /// Play pomodoro break bell (for in-app sound without notification)
  static Future<void> playPomodoroBell() async {
    await playSound('sounds/bell.wav');
  }

  /// Play completion sound
  static Future<void> playCompleteSound() async {
    await playSound('sounds/complete.wav');
  }

  /// Background task callback - checks deadlines and sends notifications
  static Future<void> backgroundCheck() async {
    if (kIsWeb) return;

    try {
      final urgent = await DeadlineService.getTasksDueWithin(
        hours: AppConfig.deadlineWarningHours,
      );
      for (final d in urgent) {
        await showUrgentDeadline(
          d.task.title,
          '${d.label} - ${d.task.subject}',
        );
      }

      final veryUrgent = await DeadlineService.getTasksDueWithin(
        hours: AppConfig.deadlineUrgentHours,
      );
      for (final d in veryUrgent) {
        await showUrgentDeadline(
          d.task.title,
          'Due in ${d.hoursUntil} hour${d.hoursUntil == 1 ? "" : "s"}!',
        );
      }
    } catch (_) {}
  }
}
