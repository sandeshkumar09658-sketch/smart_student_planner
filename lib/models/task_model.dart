/// Model class representing a student task/assignment
class TaskModel {
  int? id;
  String title;        // Task title
  String subject;      // Related subject
  String dueDate;      // Due date string
  bool isCompleted;    // Completion status
  int priority;        // 1=Low, 2=Medium, 3=High

  TaskModel({
    this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 1,
  });

  /// Convert TaskModel to Map for SQLite storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subject': subject,
    'dueDate': dueDate,
    'isCompleted': isCompleted ? 1 : 0,
    'priority': priority,
  };

  /// Create TaskModel from SQLite Map
  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'],
    title: map['title'],
    subject: map['subject'],
    dueDate: map['dueDate'],
    isCompleted: map['isCompleted'] == 1,
    priority: map['priority'],
  );
}