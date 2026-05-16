import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// Study Planner screen - schedule study sessions by day
class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  // In-memory study plan sessions list
  final List<Map<String, String>> _sessions = [];
  final List<String> _days = [
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
  ];
  String _selectedDay = 'Monday';

  /// Add a new study session
  void _showAddSession() {
    final subjectCtrl = TextEditingController();
    final timeCtrl    = TextEditingController();
    final durationCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 24, right: 24, top: 24,
        ),
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
            const Text('Add Study Session',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: subjectCtrl,
              decoration: InputDecoration(
                labelText: 'Subject',
                prefixIcon: const Icon(Icons.book_rounded, color: Color(0xFFFF6B6B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              decoration: InputDecoration(
                labelText: 'Time (e.g. 10:00 AM)',
                prefixIcon: const Icon(Icons.access_time, color: Color(0xFFFF6B6B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Duration (minutes)',
                prefixIcon: const Icon(Icons.timer, color: Color(0xFFFF6B6B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (subjectCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _sessions.add({
                      'day':      _selectedDay,
                      'subject':  subjectCtrl.text.trim(),
                      'time':     timeCtrl.text.trim(),
                      'duration': '${durationCtrl.text} min',
                    });
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add Session',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter sessions by selected day
    final filtered = _sessions.where((s) => s['day'] == _selectedDay).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Planner')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSession,
        backgroundColor: const Color(0xFFFF6B6B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Session', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Day selector horizontal scroll
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF6B6B)
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

          // Sessions list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No sessions for $_selectedDay',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      return FadeInUp(
                        delay: Duration(milliseconds: i * 80),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B6B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.menu_book_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            title: Text(s['subject']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text('${s['time']}  •  ${s['duration']}',
                                style: const TextStyle(color: Colors.grey)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () {
                                setState(() => _sessions.remove(s));
                              },
                            ),
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