/// Model class representing attendance record for a subject
class AttendanceModel {
  int? id;
  String subject;      // Subject name
  int totalClasses;    // Total classes held
  int attended;        // Classes attended

  AttendanceModel({
    this.id,
    required this.subject,
    required this.totalClasses,
    required this.attended,
  });

  /// Calculate attendance percentage
  double get percentage =>
      totalClasses == 0 ? 0 : (attended / totalClasses) * 100;

  /// Convert to Map for SQLite
  Map<String, dynamic> toMap() => {
    'id': id,
    'subject': subject,
    'totalClasses': totalClasses,
    'attended': attended,
  };

  /// Create from SQLite Map
  factory AttendanceModel.fromMap(Map<String, dynamic> map) => AttendanceModel(
    id: map['id'],
    subject: map['subject'],
    totalClasses: map['totalClasses'],
    attended: map['attended'],
  );
}