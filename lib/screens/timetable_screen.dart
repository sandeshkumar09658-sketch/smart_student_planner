import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

/// Timetable screen - weekly class schedule manager
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final List<String> _days = [
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'
  ];
  String _selectedDay = 'Monday';

  /// Color options for subject cards
  final List<Color> _colors = [
    const Color(0xFF6C63FF), const Color(0xFF00D2D3),
    const Color(0xFFFF6B6B), const Color(0xFF26de81),
    const Color(0xFFfdcb6e), const Color(0xFF74b9ff),
  ];

  /// All classes stored in memory
  final List<Map<String, dynamic>> _classes = [];

  /// Show dialog to add a new class slot
  void _showAddClass() {
    final subjectCtrl  = TextEditingController();
    final teacherCtrl  = TextEditingController();
    final roomCtrl     = TextEditingController();
    final timeCtrl     = TextEditingController();
    int colorIndex     = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 24, right: 24, top: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 16),
                const Text('Add Class',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: subjectCtrl,
                  decoration: InputDecoration(labelText: 'Subject Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: teacherCtrl,
                  decoration: InputDecoration(labelText: 'Teacher Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: timeCtrl,
                    decoration: InputDecoration(labelText: 'Time (e.g 9:00 AM)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: roomCtrl,
                    decoration: InputDecoration(labelText: 'Room No.',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))))),
                ]),
                const SizedBox(height: 12),
                const Text('Color:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: List.generate(_colors.length, (i) =>
                  GestureDetector(
                    onTap: () => setModal(() => colorIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: _colors[i],
                        shape: BoxShape.circle,
                        border: colorIndex == i
                            ? Border.all(color: Colors.black, width: 2.5)
                            : null,
                      ),
                      child: colorIndex == i
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF74b9ff),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (subjectCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _classes.add({
                          'day':        _selectedDay,
                          'subject':    subjectCtrl.text.trim(),
                          'teacher':    teacherCtrl.text.trim(),
                          'time':       timeCtrl.text.trim(),
                          'room':       roomCtrl.text.trim(),
                          'colorIndex': colorIndex,
                        });
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Add Class',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _classes
        .where((c) => c['day'] == _selectedDay)
        .toList()
      ..sort((a, b) => a['time'].compareTo(b['time']));

    return Scaffold(
      appBar: AppBar(title: const Text('Class Timetable')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClass,
        backgroundColor: const Color(0xFF74b9ff),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Class', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Day selector
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _days.length,
              itemBuilder: (_, i) {
                final isSelected = _days[i] == _selectedDay;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = _days[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF74b9ff), Color(0xFF0984e3)])
                          : null,
                      color: isSelected
                          ? null
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(_days[i].substring(0, 3),
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ),

          // Class cards
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.table_chart_rounded,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No classes on $_selectedDay',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c     = filtered[i];
                      final color = _colors[c['colorIndex']];
                      return FadeInUp(
                        delay: Duration(milliseconds: i * 80),
                        child: Dismissible(
                          key: Key('$i${c['subject']}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_rounded,
                                color: Colors.white),
                          ),
                          onDismissed: (_) =>
                              setState(() => _classes.remove(c)),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: color.withOpacity(0.3)),
                              color: color.withOpacity(0.08),
                            ),
                            child: Row(children: [
                              // Time bar on left
                              Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  c['time'].isEmpty ? '--' : c['time'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(c['subject'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      if (c['teacher'].isNotEmpty)
                                        Text('👨‍🏫 ${c['teacher']}',
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13)),
                                      if (c['room'].isNotEmpty)
                                        Text('🚪 Room ${c['room']}',
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}