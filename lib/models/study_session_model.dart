class StudySessionModel {
  final String id;
  final String day;
  final String subject;
  final String time;
  final int durationMins;
  final String notes;
  final String topic;
  final int colorIndex;
  bool isCompleted;

  StudySessionModel({
    required this.id,
    required this.day,
    required this.subject,
    required this.time,
    required this.durationMins,
    this.notes = '',
    this.topic = '',
    this.colorIndex = 0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'day': day, 'subject': subject,
    'time': time, 'durationMins': durationMins,
    'notes': notes, 'topic': topic,
    'colorIndex': colorIndex, 'isCompleted': isCompleted,
  };

  factory StudySessionModel.fromMap(Map<String, dynamic> m) => StudySessionModel(
    id: m['id'], day: m['day'], subject: m['subject'],
    time: m['time'], durationMins: m['durationMins'],
    notes: m['notes'] ?? '', topic: m['topic'] ?? '',
    colorIndex: m['colorIndex'] ?? 0,
    isCompleted: m['isCompleted'] ?? false,
  );
}
