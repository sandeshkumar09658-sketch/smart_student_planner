import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../models/attendance_model.dart';

/// Web-compatible storage helper using SharedPreferences
/// Replaces SQLite so the app works in Chrome browser
class DBHelper {

  // ─── TASK OPERATIONS ───────────────────────────────────────────

  /// Get all tasks from local storage
  static Future<List<TaskModel>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('tasks');
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => TaskModel.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  /// Save all tasks to local storage
  static Future<void> _saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((t) => t.toMap()).toList();
    await prefs.setString('tasks', jsonEncode(jsonList));
  }

  /// Insert a new task
  static Future<void> insertTask(TaskModel task) async {
    final tasks = await getTasks();
    // Generate a simple id based on timestamp
    task.id = DateTime.now().millisecondsSinceEpoch;
    tasks.add(task);
    await _saveTasks(tasks);
  }

  /// Update an existing task
  static Future<void> updateTask(TaskModel task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) tasks[index] = task;
    await _saveTasks(tasks);
  }

  /// Delete a task by id
  static Future<void> deleteTask(int id) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _saveTasks(tasks);
  }

  // ─── ATTENDANCE OPERATIONS ─────────────────────────────────────

  /// Get all attendance records from local storage
  static Future<List<AttendanceModel>> getAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('attendance');
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => AttendanceModel.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  /// Save all attendance records to local storage
  static Future<void> _saveAttendance(List<AttendanceModel> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => r.toMap()).toList();
    await prefs.setString('attendance', jsonEncode(jsonList));
  }

  /// Insert a new attendance record
  static Future<void> insertAttendance(AttendanceModel att) async {
    final records = await getAttendance();
    att.id = DateTime.now().millisecondsSinceEpoch;
    records.add(att);
    await _saveAttendance(records);
  }

  /// Update an existing attendance record
  static Future<void> updateAttendance(AttendanceModel att) async {
    final records = await getAttendance();
    final index = records.indexWhere((r) => r.id == att.id);
    if (index != -1) records[index] = att;
    await _saveAttendance(records);
  }

  /// Delete an attendance record by id
  static Future<void> deleteAttendance(int id) async {
    final records = await getAttendance();
    records.removeWhere((r) => r.id == id);
    await _saveAttendance(records);
  }
}