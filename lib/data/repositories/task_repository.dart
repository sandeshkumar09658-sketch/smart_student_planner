import 'package:hive/hive.dart';
import '../../models/task_model.dart';

class TaskRepository {
  static Box<TaskModel> get _box => Hive.box<TaskModel>('tasks');

  static List<TaskModel> _nonNull(Iterable<TaskModel?> items) =>
      items.whereType<TaskModel>().toList();

  static Future<List<TaskModel>> getTasks() async {
    return _nonNull(_box.values);
  }

  static Future<void> addTask(TaskModel task) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    task.id = id;
    await _box.put(id, task);
  }

  static Future<void> updateTask(TaskModel task) async {
    await _box.put(task.id!, task);
  }

  static Future<void> deleteTask(int id) async {
    await _box.delete(id);
  }

  static Future<void> toggleComplete(int id) async {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await _box.put(id, task);
    }
  }

  static Future<int> getPendingCount() async {
    return _nonNull(_box.values).where((t) => !t.isCompleted).length;
  }

  static Future<int> getCompletedCount() async {
    return _nonNull(_box.values).where((t) => t.isCompleted).length;
  }
}
