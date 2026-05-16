import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../database/db_helper.dart';
import '../models/task_model.dart';
import '../models/attendance_model.dart';
import '../theme/app_theme.dart';

/// Progress screen - overall academic progress overview
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<TaskModel>       _tasks   = [];
  List<AttendanceModel> _records = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks   = await DBHelper.getTasks();
    final records = await DBHelper.getAttendance();
    setState(() {
      _tasks   = tasks;
      _records = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total     = _tasks.length;
    final completed = _tasks.where((t) => t.isCompleted).length;
    final taskPct   = total == 0 ? 0.0 : completed / total;
    final avgAtt    = _records.isEmpty
        ? 0.0
        : _records.map((r) => r.percentage).reduce((a, b) => a + b) /
            _records.length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Overview Cards ─────────────────────────────
            FadeInDown(
              child: Row(
                children: [
                  Expanded(child: _summaryCard('Tasks Done',
                      '$completed / $total', Icons.task_alt,
                      AppTheme.primaryColor)),
                  const SizedBox(width: 12),
                  Expanded(child: _summaryCard('Avg Attendance',
                      '${avgAtt.toStringAsFixed(1)}%',
                      Icons.co_present_rounded, AppTheme.accentColor)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Task Completion Circle ──────────────────────
            FadeInLeft(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 56,
                        lineWidth: 10,
                        percent: taskPct.clamp(0.0, 1.0),
                        center: Text('${(taskPct * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        progressColor: AppTheme.primaryColor,
                        backgroundColor: Colors.grey.shade200,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Task Completion',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text('$completed tasks completed out of $total',
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: taskPct.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.shade200,
                              color: AppTheme.primaryColor,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Subject Attendance Breakdown ────────────────
            if (_records.isNotEmpty) ...[
              const Text('Subject-wise Attendance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._records.asMap().entries.map((e) {
                final i   = e.key;
                final rec = e.value;
                final pct = rec.percentage / 100;
                return FadeInUp(
                  delay: Duration(milliseconds: i * 100),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(rec.subject,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text('${rec.percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      color: rec.percentage >= 75
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: pct.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.shade200,
                            color: rec.percentage >= 75
                                ? Colors.green
                                : Colors.red,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  /// Summary card widget for top stats
  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}