import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/attendance_model.dart';

/// Database helper class for all SQLite operations
class DBHelper {
  static Database? _db;
  static const String _dbName = 'student_planner.db';

  /// Get or create database instance (Singleton pattern)
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Initialize and create the database
  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create tasks table
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            subject TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            isCompleted INTEGER DEFAULT 0,
            priority INTEGER DEFAULT 1
          )
        ''');

        // Create attendance table
        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT NOT NULL,
            totalClasses INTEGER DEFAULT 0,
            attended INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // ─── TASK OPERATIONS ───────────────────────────────────────────

  /// Insert a new task into database
  static Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  /// Get all tasks from database
  static Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'priority DESC');
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  /// Update an existing task
  static Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  /// Delete a task by id
  static Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ─── ATTENDANCE OPERATIONS ─────────────────────────────────────

  /// Insert a new attendance record
  static Future<int> insertAttendance(AttendanceModel att) async {
    final db = await database;
    return db.insert('attendance', att.toMap());
  }

  /// Get all attendance records
  static Future<List<AttendanceModel>> getAttendance() async {
    final db = await database;
    final maps = await db.query('attendance');
    return maps.map((m) => AttendanceModel.fromMap(m)).toList();
  }

  /// Update attendance record
  static Future<int> updateAttendance(AttendanceModel att) async {
    final db = await database;
    return db.update('attendance', att.toMap(), where: 'id = ?', whereArgs: [att.id]);
  }

  /// Delete attendance record by id
  static Future<int> deleteAttendance(int id) async {
    final db = await database;
    return db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }
}