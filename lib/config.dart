/// App configuration constants
class AppConfig {
  AppConfig._();

  /// Google Gemini API key — replace with your own key
  /// Get one at https://aistudio.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyC4tsVbpAdZ2crJBMZf2MJ36oaNRpGTjsg';

  /// Gemini model to use
  static const String geminiModel = 'gemini-2.0-flash';

  /// Base URL for Gemini API
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Notification IDs
  static const int notifIdStudyReminder = 1;
  static const int notifIdTaskReminder = 2;
  static const int notifIdAttendanceWarning = 3;
  static const int notifIdPomodoroComplete = 4;
  static const int notifIdDeadlineUrgent = 5;
  static const int notifIdDailyDigest = 6;

  /// Deadline thresholds (in hours)
  static const int deadlineWarningHours = 24;
  static const int deadlineUrgentHours = 1;

  /// Background task interval (minutes)
  static const int backgroundCheckIntervalMin = 60;
}
