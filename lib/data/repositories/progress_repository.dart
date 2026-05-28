import 'package:hive/hive.dart';

class ProgressRepository {
  static Box<Map> get _streakBox => Hive.box<Map>('streak');
  static Box<Map> get _achievementBox => Hive.box<Map>('achievements');
  static Box<Map> get _coursesBox => Hive.box<Map>('courses');

  // --- Streak ---

  static Future<int> getCurrentStreak() async {
    final data = _streakBox.get('streak');
    return (data?['current'] ?? 0) as int;
  }

  static Future<int> getLongestStreak() async {
    final data = _streakBox.get('streak');
    return (data?['longest'] ?? 0) as int;
  }

  static Future<void> markDayActive() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final data = _streakBox.get('streak') ?? <String, dynamic>{};
    final lastDate = data['lastDate'] as String? ?? '';

    if (lastDate == today) return;

    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    if (lastDate == yesterday) {
      data['current'] = ((data['current'] as int?) ?? 0) + 1;
    } else {
      data['current'] = 1;
    }
    data['lastDate'] = today;
    final current = data['current'] as int;
    final longest = data['longest'] as int? ?? 0;
    if (current > longest) {
      data['longest'] = current;
    }
    await _streakBox.put('streak', data);
  }

  // --- GPA / Courses ---

  static Future<List<Map>> getCourses() async {
    return _coursesBox.values.toList();
  }

  static Future<void> addCourse(Map course) async {
    await _coursesBox.put(course['name'], course);
  }

  static Future<void> removeCourse(String name) async {
    await _coursesBox.delete(name);
  }

  static Future<double> getGpa() async {
    final courses = _coursesBox.values.toList();
    if (courses.isEmpty) return 0.0;
    final grades = {
      'A+': 4.0, 'A': 4.0, 'A-': 3.7, 'B+': 3.3, 'B': 3.0, 'B-': 2.7,
      'C+': 2.3, 'C': 2.0, 'C-': 1.7, 'D': 1.0, 'F': 0.0,
    };
    double totalPoints = 0;
    int totalCredits = 0;
    for (final c in courses) {
      final grade = grades[c['grade']] ?? 0.0;
      final credits = (c['credits'] as num?)?.toInt() ?? 3;
      totalPoints += grade * credits;
      totalCredits += credits;
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  // --- Achievements ---

  static Future<List<Map>> getAchievements() async {
    return _achievementBox.values.toList();
  }

  static Future<void> unlockAchievement(String id, String title, String icon) async {
    if (_achievementBox.containsKey(id)) return;
    await _achievementBox.put(id, {
      'id': id,
      'title': title,
      'icon': icon,
      'unlockedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> isAchievementUnlocked(String id) async {
    return _achievementBox.containsKey(id);
  }
}
