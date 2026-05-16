import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../database/db_helper.dart';
import '../models/attendance_model.dart';
import '../theme/app_theme.dart';

/// Attendance screen - track subject-wise attendance
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<AttendanceModel> _records = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DBHelper.getAttendance();
    setState(() => _records = data);
  }

  /// Show dialog to add a new subject
  void _showAddDialog() {
    final subjectCtrl = TextEditingController();
    final totalCtrl   = TextEditingController();
    final attendedCtrl = TextEditingController();

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
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            const Text('Add Subject',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: subjectCtrl,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                prefixIcon: const Icon(Icons.book_rounded, color: AppTheme.accentColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total Classes',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: attendedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Attended',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final total    = int.tryParse(totalCtrl.text) ?? 0;
                  final attended = int.tryParse(attendedCtrl.text) ?? 0;
                  if (subjectCtrl.text.trim().isEmpty || total == 0) return;
                  await DBHelper.insertAttendance(AttendanceModel(
                    subject: subjectCtrl.text.trim(),
                    totalClasses: total,
                    attended: attended,
                  ));
                  if (!mounted) return;
                  Navigator.pop(context);
                  _load();
                },
                child: const Text('Save',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Color based on attendance percentage
  Color _attendanceColor(double pct) {
    if (pct >= 75) return Colors.green;
    if (pct >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Subject', style: TextStyle(color: Colors.white)),
      ),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.co_present_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('No subjects added yet',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: _records.length,
              itemBuilder: (ctx, i) {
                final rec = _records[i];
                final pct = rec.percentage;
                return FadeInUp(
                  delay: Duration(milliseconds: i * 80),
                  child: Dismissible(
                    key: Key(rec.id.toString()),
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
                          color: Colors.white, size: 28),
                    ),
                    onDismissed: (_) async {
                      await DBHelper.deleteAttendance(rec.id!);
                      _load();
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Circular progress indicator
                            CircularPercentIndicator(
                              radius: 36,
                              lineWidth: 6,
                              percent: (pct / 100).clamp(0.0, 1.0),
                              center: Text('${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _attendanceColor(pct))),
                              progressColor: _attendanceColor(pct),
                              backgroundColor: Colors.grey.shade200,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(rec.subject,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '${rec.attended} / ${rec.totalClasses} classes attended',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  // Warning if attendance is low
                                  if (pct < 75)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('⚠️ Below 75%',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                ],
                              ),
                            ),
                            // Quick +1 buttons
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  tooltip: 'Present',
                                  onPressed: () async {
                                    rec.totalClasses++;
                                    rec.attended++;
                                    await DBHelper.updateAttendance(rec);
                                    _load();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  tooltip: 'Absent',
                                  onPressed: () async {
                                    rec.totalClasses++;
                                    await DBHelper.updateAttendance(rec);
                                    _load();
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}