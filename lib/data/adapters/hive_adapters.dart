import 'package:hive/hive.dart';
import '../../models/study_session_model.dart';
import '../../models/task_model.dart';
import '../../models/attendance_model.dart';

class StudySessionModelAdapter extends TypeAdapter<StudySessionModel> {
  @override
  final int typeId = 0;

  @override
  StudySessionModel read(BinaryReader reader) {
    final fields = reader.readMap().cast<String, dynamic>();
    return StudySessionModel(
      id: fields['id'] as String,
      day: fields['day'] as String,
      subject: fields['subject'] as String,
      time: fields['time'] as String,
      durationMins: fields['durationMins'] as int,
      notes: fields['notes'] as String? ?? '',
      topic: fields['topic'] as String? ?? '',
      colorIndex: fields['colorIndex'] as int? ?? 0,
      isCompleted: fields['isCompleted'] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, StudySessionModel obj) {
    writer.writeMap({
      'id': obj.id,
      'day': obj.day,
      'subject': obj.subject,
      'time': obj.time,
      'durationMins': obj.durationMins,
      'notes': obj.notes,
      'topic': obj.topic,
      'colorIndex': obj.colorIndex,
      'isCompleted': obj.isCompleted,
    });
  }
}

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 1;

  @override
  TaskModel read(BinaryReader reader) {
    final fields = reader.readMap().cast<String, dynamic>();
    return TaskModel(
      id: fields['id'] as int?,
      title: fields['title'] as String,
      subject: fields['subject'] as String,
      dueDate: fields['dueDate'] as String,
      isCompleted: fields['isCompleted'] as bool? ?? false,
      priority: fields['priority'] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer.writeMap({
      'id': obj.id,
      'title': obj.title,
      'subject': obj.subject,
      'dueDate': obj.dueDate,
      'isCompleted': obj.isCompleted,
      'priority': obj.priority,
    });
  }
}

class AttendanceModelAdapter extends TypeAdapter<AttendanceModel> {
  @override
  final int typeId = 2;

  @override
  AttendanceModel read(BinaryReader reader) {
    final fields = reader.readMap().cast<String, dynamic>();
    return AttendanceModel(
      id: fields['id'] as int?,
      subject: fields['subject'] as String,
      totalClasses: fields['totalClasses'] as int,
      attended: fields['attended'] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceModel obj) {
    writer.writeMap({
      'id': obj.id,
      'subject': obj.subject,
      'totalClasses': obj.totalClasses,
      'attended': obj.attended,
    });
  }
}
