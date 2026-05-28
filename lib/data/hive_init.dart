import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../models/attendance_model.dart';
import '../models/study_session_model.dart';
import 'adapters/hive_adapters.dart';

/// Hive initialization — call once before runApp()
Future<void> initHive() async {
  Hive.registerAdapter(StudySessionModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(AttendanceModelAdapter());

  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<AttendanceModel>('attendance');
  await Hive.openBox<StudySessionModel>('studySessions');
  await Hive.openBox<Map>('streak');
  await Hive.openBox<Map>('achievements');
  await Hive.openBox<Map>('courses');
  await Hive.openBox<Map>('timetable');
  await Hive.openBox<Map>('pomodoro');
}
