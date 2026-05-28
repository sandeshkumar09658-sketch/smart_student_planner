import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/study_repository.dart';
import '../data/repositories/task_repository.dart';

class AiService {
  static String get _apiUrl =>
      '${AppConfig.geminiBaseUrl}/${AppConfig.geminiModel}:generateContent?key=${AppConfig.geminiApiKey}';

  static Future<String> _buildContextPrompt() async {
    final tasks = await TaskRepository.getTasks();
    final attendance = await AttendanceRepository.getAll();
    final gpa = await ProgressRepository.getGpa();
    final courses = await ProgressRepository.getCourses();
    final achievements = await ProgressRepository.getAchievements();
    final streak = await ProgressRepository.getCurrentStreak();
    final weekMinutes = await StudyRepository.getWeekMinutes();
    final todayFocus = await StudyRepository.getTodayFocusMinutes();

    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    final totalClasses = attendance.fold<int>(0, (s, a) => s + a.totalClasses);
    final attended = attendance.fold<int>(0, (s, a) => s + a.attended);
    final attendancePct = totalClasses > 0 ? (attended / totalClasses * 100).toStringAsFixed(1) : 'N/A';
    final totalWeekMins = weekMinutes.values.fold<int>(0, (s, v) => s + v);

    final buf = StringBuffer();
    buf.writeln('You are a helpful AI study assistant for a student app called StudyFlow.');
    buf.writeln('Only answer based on the student\'s actual data below. If the data is insufficient, say so and suggest what to add.');
    buf.writeln('Keep responses concise, practical, and actionable. Maximum 3-4 sentences unless asked for details.');
    buf.writeln('Here is the student\'s current data:');
    buf.writeln('');
    buf.writeln('TASKS');
    buf.writeln('- Pending tasks: ${pendingTasks.length}');
    buf.writeln('- Completed tasks: ${completedTasks.length}');
    buf.writeln('- Total tasks: ${tasks.length}');
    if (pendingTasks.isNotEmpty) {
      buf.writeln('- Upcoming tasks:');
      for (final t in pendingTasks.take(5)) {
        buf.writeln('  * ${t.title} (${t.subject}, due: ${t.dueDate}, priority: ${t.priority == 3 ? 'High' : t.priority == 2 ? 'Medium' : 'Low'})');
      }
    }
    buf.writeln('');
    buf.writeln('ATTENDANCE');
    buf.writeln('- Overall attendance: $attendancePct%');
    if (attendance.isNotEmpty) {
      for (final a in attendance) {
        buf.writeln('  * ${a.subject}: ${a.percentage.toStringAsFixed(1)}% (${a.attended}/${a.totalClasses} classes)');
      }
    } else {
      buf.writeln('- No attendance records yet.');
    }
    buf.writeln('');
    buf.writeln('ACADEMICS');
    buf.writeln('- GPA: ${gpa.toStringAsFixed(2)}');
    if (courses.isNotEmpty) {
      buf.writeln('- Courses (${courses.length}):');
      for (final c in courses) {
        buf.writeln('  * ${c['name'] ?? 'Unnamed'} - Grade: ${c['grade'] ?? 'N/A'}, Credits: ${c['credits'] ?? 3}');
      }
    } else {
      buf.writeln('- No courses added yet.');
    }
    buf.writeln('');
    buf.writeln('STUDY HABITS');
    buf.writeln('- Current streak: $streak days');
    buf.writeln('- Today\'s focus minutes: $todayFocus');
    buf.writeln('- Total study minutes this week: $totalWeekMins');
    if (weekMinutes.isNotEmpty) {
      buf.writeln('- Daily breakdown:');
      weekMinutes.forEach((day, mins) {
        buf.writeln('  * $day: ${mins}min');
      });
    }
    buf.writeln('');
    if (achievements.isNotEmpty) {
      buf.writeln('ACHIEVEMENTS UNLOCKED (${achievements.length})');
      for (final a in achievements) {
        buf.writeln('- ${a['title'] ?? 'Unknown'}');
      }
      buf.writeln('');
    }
    buf.writeln('Based on this data, answer the student\'s question. Give specific, data-driven suggestions. Do not give generic advice unrelated to their actual data.');
    return buf.toString();
  }

  static Future<String> sendMessage(String message) async {
    if (AppConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      return _dataAwareFallback(message);
    }

    try {
      final context = await _buildContextPrompt();
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$context\n\nStudent: $message'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 800,
        }
      });

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No response.';
      }
      return _dataAwareFallback(message);
    } catch (_) {
      return _dataAwareFallback(message);
    }
  }

  static Future<String> getStudyTips(String subject) async {
    return sendMessage(
      'Give me 5 practical study tips for $subject based on my current workload and schedule.',
    );
  }

  static Future<String> analyzeProgress() async {
    final tasks = await TaskRepository.getTasks();
    final attendance = await AttendanceRepository.getAll();
    final gpa = await ProgressRepository.getGpa();
    final total = tasks.length;
    final done = tasks.where((t) => t.isCompleted).length;
    final pct = total > 0 ? (done / total * 100).toStringAsFixed(1) : '0';
    final attCount = attendance.length;

    return sendMessage(
      'Analyze my academic progress. I have completed $done out of $total tasks ($pct%). '
      'My GPA is $gpa. I track $attCount attendance subjects. '
      'Give me a brief assessment and 3 specific suggestions based on this data.',
    );
  }

  static Future<String> generateStudyPlan() async {
    final tasks = await TaskRepository.getTasks();
    final pending = tasks.where((t) => !t.isCompleted).toList();
    final subjects = pending.map((t) => t.subject).toSet().toList();
    final weekMins = await StudyRepository.getWeekMinutes();
    final totalWeekMins = weekMins.values.fold<int>(0, (s, v) => s + v);

    return sendMessage(
      'Create a focused study plan for today. I need to work on: ${subjects.join(", ")}. '
      'I have ${pending.length} pending tasks. I studied $totalWeekMins minutes this week. '
      'Suggest a time-blocked schedule based on my workload.',
    );
  }

  static Future<String> _dataAwareFallback(String message) async {
    final tasks = await TaskRepository.getTasks();
    final attendance = await AttendanceRepository.getAll();
    final gpa = await ProgressRepository.getGpa();
    final streak = await ProgressRepository.getCurrentStreak();
    final todayFocus = await StudyRepository.getTodayFocusMinutes();

    final pending = tasks.where((t) => !t.isCompleted).toList();
    final done = tasks.where((t) => t.isCompleted).toList();

    final totalClasses = attendance.fold<int>(0, (s, a) => s + a.totalClasses);
    final attended = attendance.fold<int>(0, (s, a) => s + a.attended);
    final attPct = totalClasses > 0 ? (attended / totalClasses * 100).toStringAsFixed(1) : 'N/A';

    final dataSummary = StringBuffer();
    dataSummary.writeln('Here is your current academic snapshot:');
    dataSummary.writeln('- Tasks: ${done.length} done, ${pending.length} pending');
    dataSummary.writeln('- GPA: ${gpa.toStringAsFixed(2)}');
    dataSummary.writeln('- Attendance: $attPct%');
    dataSummary.writeln('- Streak: $streak days');
    dataSummary.writeln('- Focus today: $todayFocus min');
    dataSummary.writeln('');

    final msg = message.toLowerCase();

    if (pending.isNotEmpty && (msg.contains('task') || msg.contains('priority') || msg.contains('what') || msg.contains('next'))) {
      final next = pending.first;
      return '${dataSummary}Your next task is "${next.title}" for ${next.subject}, due ${next.dueDate}. '
          'It has ${next.priority == 3 ? 'high' : next.priority == 2 ? 'medium' : 'low'} priority. '
          'I suggest starting with high-priority items first. Would you like me to help plan your study session?';
    }
    if (msg.contains('study') || msg.contains('tip') || msg.contains('focus')) {
      return '${dataSummary}Based on your data, you\'ve studied $todayFocus minutes today '
          'with a $streak-day streak. '
          'To stay productive: use the Pomodoro technique (25 min focus, 5 min break), '
          'tackle your ${pending.length} pending tasks one at a time, and review material using active recall.';
    }
    if (msg.contains('exam') || msg.contains('test') || msg.contains('prepare')) {
      return '${dataSummary}You have ${pending.length} pending tasks. '
          'For exam prep: break material into small chunks, practice with active recall, '
          'and use past papers if available. '
          'Your ${done.length} completed tasks show you\'re making progress. Keep it up!';
    }
    if (msg.contains('progress') || msg.contains('gpa') || msg.contains('grade')) {
      return '${dataSummary}Your GPA is ${gpa.toStringAsFixed(2)} with ${done.length} tasks completed. '
          'Attendance is at $attPct%. '
          'To improve: focus on completing pending tasks, maintain consistent attendance, and review weak subjects.';
    }
    if (msg.contains('time') || msg.contains('schedule') || msg.contains('plan')) {
      return '${dataSummary}You have ${pending.length} pending tasks across ${pending.map((t) => t.subject).toSet().length} subjects. '
          'I recommend blocking 1-2 hours of focused study, starting with the nearest deadline. '
          'Your current streak is $streak days. Stay consistent!';
    }
    return '${dataSummary}I\'m your study assistant. I can help with: '
        'task prioritization (you have ${pending.length} pending), study tips based on your $todayFocus min focus time, '
        'attendance analysis ($attPct%), and GPA guidance (${gpa.toStringAsFixed(2)}). What would you like?';
  }
}
