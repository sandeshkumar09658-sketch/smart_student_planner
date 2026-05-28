import 'package:intl/intl.dart';
import '../data/repositories/task_repository.dart';
import '../models/task_model.dart';

/// Service for deadline-related calculations and checks
class DeadlineService {
  /// Parse a date string (format: 'dd MMM yyyy') to DateTime
  static DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('dd MMM yyyy').parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Get all pending tasks with their deadline info
  static Future<List<DeadlineTask>> getDeadlineTasks() async {
    final tasks = await TaskRepository.getTasks();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = <DeadlineTask>[];
    for (final t in tasks.where((t) => !t.isCompleted)) {
      final dueDate = _parseDate(t.dueDate);
      if (dueDate == null) continue;
      final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final daysUntil = dueDay.difference(today).inDays;
      final hoursUntil = dueDate.difference(now).inHours;

      DeadlineUrgency urgency;
      String label;
      ColorCode color;

      if (daysUntil < 0) {
        urgency = DeadlineUrgency.overdue;
        label = 'Overdue!';
        color = ColorCode.red;
      } else if (daysUntil == 0) {
        urgency = DeadlineUrgency.today;
        label = 'Due today!';
        color = ColorCode.red;
      } else if (daysUntil == 1) {
        urgency = DeadlineUrgency.tomorrow;
        label = 'Due tomorrow';
        color = ColorCode.orange;
      } else if (daysUntil <= 3) {
        urgency = DeadlineUrgency.soon;
        label = 'Due in $daysUntil days';
        color = ColorCode.orange;
      } else if (daysUntil <= 7) {
        urgency = DeadlineUrgency.week;
        label = 'Due in $daysUntil days';
        color = ColorCode.yellow;
      } else {
        urgency = DeadlineUrgency.far;
        label = 'Due in $daysUntil days';
        color = ColorCode.green;
      }

      result.add(DeadlineTask(
        task: t,
        dueDate: dueDate,
        daysUntil: daysUntil,
        hoursUntil: hoursUntil,
        urgency: urgency,
        label: label,
        color: color,
      ));
    }

    result.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return result;
  }

  /// Check if there are any urgent tasks (due within warning threshold)
  static Future<List<DeadlineTask>> getUrgentTasks() async {
    final tasks = await getDeadlineTasks();
    return tasks.where((t) =>
        t.urgency == DeadlineUrgency.overdue ||
        t.urgency == DeadlineUrgency.today ||
        t.urgency == DeadlineUrgency.tomorrow ||
        t.urgency == DeadlineUrgency.soon
    ).toList();
  }

  /// Get tasks due within specified hours
  static Future<List<DeadlineTask>> getTasksDueWithin({int hours = 24}) async {
    final tasks = await getDeadlineTasks();
    return tasks.where((t) =>
        t.hoursUntil >= 0 && t.hoursUntil <= hours
    ).toList();
  }

  /// Get count of tasks due within warning threshold
  static Future<int> getUrgentCount() async {
    final urgent = await getUrgentTasks();
    return urgent.length;
  }
}

/// Deadline-aware task wrapper
class DeadlineTask {
  final TaskModel task;
  final DateTime dueDate;
  final int daysUntil;
  final int hoursUntil;
  final DeadlineUrgency urgency;
  final String label;
  final ColorCode color;

  DeadlineTask({
    required this.task,
    required this.dueDate,
    required this.daysUntil,
    required this.hoursUntil,
    required this.urgency,
    required this.label,
    required this.color,
  });
}

enum DeadlineUrgency { overdue, today, tomorrow, soon, week, far }

enum ColorCode { red, orange, yellow, green }
