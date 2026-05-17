import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Study Session model with all details
class StudySession {
  final String id;
  final String day;
  final String subject;
  final String time;
  final int durationMins;
  final String notes;
  final String topic;
  final int colorIndex;
  bool isCompleted;

  StudySession({
    required this.id,
    required this.day,
    required this.subject,
    required this.time,
    required this.durationMins,
    required this.notes,
    required this.topic,
    required this.colorIndex,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'day': day, 'subject': subject,
    'time': time, 'durationMins': durationMins,
    'notes': notes, 'topic': topic,
    'colorIndex': colorIndex, 'isCompleted': isCompleted,
  };

  factory StudySession.fromMap(Map<String, dynamic> m) => StudySession(
    id: m['id'], day: m['day'], subject: m['subject'],
    time: m['time'], durationMins: m['durationMins'],
    notes: m['notes'] ?? '', topic: m['topic'] ?? '',
    colorIndex: m['colorIndex'], isCompleted: m['isCompleted'] ?? false,
  );
}

/// Advanced Study Planner - VIP version with full features
class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<StudySession> _sessions = [];
  bool _isLoading = true;

  final List<String> _days = [
    'Monday','Tuesday','Wednesday',
    'Thursday','Friday','Saturday','Sunday'
  ];

  final List<Color> _colors = [
    const Color(0xFF6C63FF), const Color(0xFFFF6B6B),
    const Color(0xFF00D2D3), const Color(0xFF26de81),
    const Color(0xFFfdcb6e), const Color(0xFF74b9ff),
  ];

  // Today's day name
  String get _today => DateFormat('EEEE').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Tab 0 = Today, Tab 1-7 = each day
    _tabController = TabController(length: 8, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load sessions from SharedPreferences
  Future<void> _load() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final data  = prefs.getString('study_sessions');
    if (data != null) {
      final List list = jsonDecode(data);
      _sessions = list.map((e) => StudySession.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    setState(() => _isLoading = false);
  }

  /// Save sessions to SharedPreferences
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'study_sessions',
      jsonEncode(_sessions.map((s) => s.toMap()).toList()),
    );
  }

  /// Get sessions for a specific day
  List<StudySession> _sessionsForDay(String day) {
    final list = _sessions.where((s) => s.day == day).toList();
    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  /// Total study minutes for a day
  int _totalMinsForDay(String day) =>
      _sessionsForDay(day).fold(0, (sum, s) => sum + s.durationMins);

  /// Completed sessions count for a day
  int _completedForDay(String day) =>
      _sessionsForDay(day).where((s) => s.isCompleted).length;

  /// Show bottom sheet to add a new session
  void _showAddSession(String defaultDay) {
    final subjectCtrl = TextEditingController();
    final topicCtrl   = TextEditingController();
    final notesCtrl   = TextEditingController();
    final timeCtrl    = TextEditingController();
    int duration      = 60;
    int colorIndex    = 0;
    String day        = defaultDay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 24, right: 24, top: 20,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 16),
                const Text('Add Study Session',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Subject
                _inputField(subjectCtrl, 'Subject Name',
                    Icons.book_rounded, _colors[colorIndex]),
                const SizedBox(height: 10),

                // Topic
                _inputField(topicCtrl, 'Topic to Study (e.g Chapter 3)',
                    Icons.topic_rounded, _colors[colorIndex]),
                const SizedBox(height: 10),

                // Time + Duration row
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: timeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: Icon(Icons.access_time,
                            color: _colors[colorIndex]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setModal(() => timeCtrl.text =
                              picked.format(context));
                        }
                      },
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: duration,
                      decoration: InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [30, 45, 60, 90, 120].map((v) =>
                        DropdownMenuItem(value: v,
                            child: Text('$v min'))).toList(),
                      onChanged: (v) => setModal(() => duration = v!),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),

                // Day selector
                const Text('Day:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: _days.map((d) {
                    final isSel = d == day;
                    return GestureDetector(
                      onTap: () => setModal(() => day = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel
                              ? _colors[colorIndex]
                              : _colors[colorIndex].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(d.substring(0, 3),
                            style: TextStyle(
                                color: isSel ? Colors.white : _colors[colorIndex],
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                // Color picker
                const Text('Color:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: List.generate(_colors.length, (i) =>
                  GestureDetector(
                    onTap: () => setModal(() => colorIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: _colors[i],
                        shape: BoxShape.circle,
                        border: colorIndex == i
                            ? Border.all(color: Colors.black, width: 2.5)
                            : null,
                        boxShadow: colorIndex == i
                            ? [BoxShadow(
                                color: _colors[i].withOpacity(0.5),
                                blurRadius: 8)]
                            : null,
                      ),
                      child: colorIndex == i
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                )),
                const SizedBox(height: 10),

                // Notes
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colors[colorIndex],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (subjectCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter subject name!')),
                        );
                        return;
                      }
                      final session = StudySession(
                        id:           DateTime.now().millisecondsSinceEpoch.toString(),
                        day:          day,
                        subject:      subjectCtrl.text.trim(),
                        topic:        topicCtrl.text.trim(),
                        time:         timeCtrl.text.trim(),
                        durationMins: duration,
                        notes:        notesCtrl.text.trim(),
                        colorIndex:   colorIndex,
                      );
                      setState(() => _sessions.add(session));
                      await _save();
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text('Save Session',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show session detail bottom sheet
  void _showDetail(StudySession s) {
    final color = _colors[s.colorIndex];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),

            // Subject header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.subject,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  if (s.topic.isNotEmpty)
                    Text(s.topic,
                        style: TextStyle(color: color, fontSize: 13)),
                ],
              )),
            ]),
            const SizedBox(height: 20),

            // Details
            _detailRow(Icons.calendar_today_rounded, 'Day', s.day, color),
            _detailRow(Icons.access_time_rounded, 'Time',
                s.time.isEmpty ? 'Not set' : s.time, color),
            _detailRow(Icons.timer_rounded, 'Duration',
                '${s.durationMins} minutes', color),
            if (s.notes.isNotEmpty)
              _detailRow(Icons.notes_rounded, 'Notes', s.notes, color),
            const SizedBox(height: 16),

            // Mark complete / delete buttons
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(s.isCompleted
                      ? Icons.refresh_rounded
                      : Icons.check_circle_rounded,
                      color: Colors.white),
                  label: Text(
                    s.isCompleted ? 'Mark Pending' : 'Mark Done',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: s.isCompleted
                        ? Colors.orange
                        : Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    setState(() => s.isCompleted = !s.isCompleted);
                    await _save();
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_rounded, color: Colors.white),
                label: const Text('Delete',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                ),
                onPressed: () async {
                  setState(() => _sessions.removeWhere((x) => x.id == s.id));
                  await _save();
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  /// Detail row widget
  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14)),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 14, color: Colors.grey))),
      ]),
    );
  }

  /// Reusable input field
  Widget _inputField(TextEditingController ctrl,
      String label, IconData icon, Color color) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }

  /// Build the session list for a given day
  Widget _buildDayView(String day) {
    final sessions = _sessionsForDay(day);
    final totalMins = _totalMinsForDay(day);
    final completed = _completedForDay(day);
    final isToday   = day == _today;

    return sessions.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note_rounded,
                    size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No sessions for $day',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 16)),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showAddSession(day),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Session'),
                ),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [

              // ── Day Summary Card ────────────────────────
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isToday
                          ? [const Color(0xFF6C63FF), const Color(0xFF9C88FF)]
                          : [Colors.grey.shade600, Colors.grey.shade500],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isToday ? '📅 Today — $day' : '📅 $day',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('$completed/${sessions.length} sessions done  •  ${totalMins ~/ 60}h ${totalMins % 60}m planned',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      // Progress circle
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          sessions.isEmpty
                              ? '0%'
                              : '${((completed / sessions.length) * 100).toInt()}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Session Cards ───────────────────────────
              ...sessions.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                final color = _colors[s.colorIndex];
                return FadeInUp(
                  delay: Duration(milliseconds: i * 80),
                  child: GestureDetector(
                    onTap: () => _showDetail(s),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: s.isCompleted
                            ? Colors.grey.withOpacity(0.08)
                            : color.withOpacity(0.08),
                        border: Border.all(
                          color: s.isCompleted
                              ? Colors.grey.withOpacity(0.2)
                              : color.withOpacity(0.3),
                        ),
                      ),
                      child: Row(children: [
                        // Left color bar
                        Container(
                          width: 6,
                          height: 90,
                          decoration: BoxDecoration(
                            color: s.isCompleted ? Colors.grey : color,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              bottomLeft: Radius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(s.subject,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            decoration: s.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: s.isCompleted
                                                ? Colors.grey
                                                : null)),
                                  ),
                                  if (s.isCompleted)
                                    const Icon(Icons.check_circle_rounded,
                                        color: Colors.green, size: 20),
                                ]),
                                if (s.topic.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(s.topic,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: color,
                                          fontWeight: FontWeight.w500)),
                                ],
                                const SizedBox(height: 6),
                                Row(children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 13, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    s.time.isEmpty
                                        ? '${s.durationMins} min'
                                        : '${s.time}  •  ${s.durationMins} min',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500),
                                  ),
                                  if (s.notes.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Icon(Icons.notes_rounded,
                                        size: 13, color: Colors.grey.shade400),
                                  ],
                                ]),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.chevron_right_rounded,
                              color: Colors.grey),
                        ),
                      ]),
                    ),
                  ),
                );
              }),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFFF6B6B),
          labelColor: const Color(0xFFFF6B6B),
          unselectedLabelColor: Colors.grey,
          tabs: [
            // Today tab
            Tab(text: '🔥 Today'),
            ..._days.map((d) => Tab(text: d.substring(0, 3))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final dayIndex = _tabController.index;
          final day = dayIndex == 0 ? _today : _days[dayIndex - 1];
          _showAddSession(day);
        },
        backgroundColor: const Color(0xFFFF6B6B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Session',
            style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Today tab
                _buildDayView(_today),
                // All days
                ..._days.map((d) => _buildDayView(d)),
              ],
            ),
    );
  }
}