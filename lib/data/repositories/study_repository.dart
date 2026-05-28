import 'package:hive/hive.dart';
import '../../models/study_session_model.dart';

class StudyRepository {
  static Box<StudySessionModel> get _box => Hive.box<StudySessionModel>('studySessions');
  static Box<Map> get _pomoBox => Hive.box<Map>('pomodoro');

  static List<StudySessionModel> _nonNull(Iterable<StudySessionModel?> items) =>
      items.whereType<StudySessionModel>().toList();

  // --- Study Sessions ---

  static Future<List<StudySessionModel>> getSessions() async {
    return _nonNull(_box.values);
  }

  static Future<List<StudySessionModel>> getTodaysSessions() async {
    final today = DateTime.now().weekday;
    final days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return _nonNull(_box.values).where((s) => s.day == days[today]).toList();
  }

  static Future<void> addSession(StudySessionModel session) async {
    await _box.put(session.id, session);
  }

  static Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }

  // --- Pomodoro Stats ---

  static Future<int> getTodayFocusMinutes() async {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    final data = _pomoBox.get(todayKey);
    return data?['minutes'] as int? ?? 0;
  }

  static Future<void> addFocusMinutes(int minutes) async {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    final data = _pomoBox.get(todayKey) ?? <String, dynamic>{};
    final current = data['minutes'] as int? ?? 0;
    data['minutes'] = current + minutes;
    await _pomoBox.put(todayKey, data);
  }

  static Future<Map<String, int>> getWeekMinutes() async {
    final result = <String, int>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = d.toIso8601String().substring(0, 10);
      final data = _pomoBox.get(key);
      result[_dayAbbr(d.weekday)] = data?['minutes'] as int? ?? 0;
    }
    return result;
  }

  static String _dayAbbr(int weekday) {
    return ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday];
  }
}
