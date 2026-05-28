import 'package:hive/hive.dart';
import '../../models/attendance_model.dart';

class AttendanceRepository {
  static Box<AttendanceModel> get _box => Hive.box<AttendanceModel>('attendance');

  static List<AttendanceModel> _nonNull(Iterable<AttendanceModel?> items) =>
      items.whereType<AttendanceModel>().toList();

  static Future<List<AttendanceModel>> getAll() async {
    return _nonNull(_box.values);
  }

  static Future<void> add(AttendanceModel att) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    att.id = id;
    await _box.put(id, att);
  }

  static Future<void> update(AttendanceModel att) async {
    await _box.put(att.id!, att);
  }

  static Future<void> delete(int id) async {
    await _box.delete(id);
  }

  static Future<double> getOverallPercentage() async {
    final records = _nonNull(_box.values);
    if (records.isEmpty) return 0;
    final total = records.fold<int>(0, (s, a) => s + a.totalClasses);
    final attended = records.fold<int>(0, (s, a) => s + a.attended);
    return total > 0 ? (attended / total) * 100 : 0;
  }
}
