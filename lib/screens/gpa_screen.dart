import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// GPA Calculator screen - calculate semester and cumulative GPA
class GpaScreen extends StatefulWidget {
  const GpaScreen({super.key});
  @override
  State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> {

  /// List of courses with name, credits, and grade
  final List<Map<String, dynamic>> _courses = [];

  /// Grade to grade point mapping (4.0 scale)
  final Map<String, double> _gradePoints = {
    'A+': 4.0, 'A': 4.0, 'A-': 3.7,
    'B+': 3.3, 'B': 3.0, 'B-': 2.7,
    'C+': 2.3, 'C': 2.0, 'C-': 1.7,
    'D': 1.0,  'F': 0.0,
  };

  String _selectedGrade = 'A';

  /// Calculate current GPA from all courses
  double get _gpa {
    if (_courses.isEmpty) return 0.0;
    double totalPoints  = 0;
    double totalCredits = 0;
    for (final c in _courses) {
      final credits = (c['credits'] as int).toDouble();
      final points  = _gradePoints[c['grade']] ?? 0.0;
      totalPoints  += credits * points;
      totalCredits += credits;
    }
    return totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
  }

  /// Get GPA status label and color
  Map<String, dynamic> get _gpaStatus {
    final gpa = _gpa;
    if (gpa >= 3.7) return {'label': 'Excellent! 🏆', 'color': Colors.green};
    if (gpa >= 3.0) return {'label': 'Good 👍',        'color': Colors.blue};
    if (gpa >= 2.0) return {'label': 'Average 📚',     'color': Colors.orange};
    return            {'label': 'Needs Work 💪',        'color': Colors.red};
  }

  /// Show dialog to add a new course
  void _showAddCourse() {
    final nameCtrl    = TextEditingController();
    final creditsCtrl = TextEditingController();
    String grade      = _selectedGrade;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 16),
              const Text('Add Course',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Course Name',
                  prefixIcon: const Icon(Icons.book_rounded,
                      color: Color(0xFFfdcb6e)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Credit Hours',
                  prefixIcon: const Icon(Icons.star_rounded,
                      color: Color(0xFFfdcb6e)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Grade:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gradePoints.keys.map((g) {
                  final isSelected = g == grade;
                  return GestureDetector(
                    onTap: () => setModal(() => grade = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFfdcb6e)
                            : const Color(0xFFfdcb6e).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFfdcb6e)),
                      ),
                      child: Text(g,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFe17055))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFfdcb6e),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty ||
                        creditsCtrl.text.trim().isEmpty) return;
                    setState(() {
                      _courses.add({
                        'name':    nameCtrl.text.trim(),
                        'credits': int.tryParse(creditsCtrl.text) ?? 3,
                        'grade':   grade,
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Add Course',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _gpaStatus;
    return Scaffold(
      appBar: AppBar(title: const Text('GPA Calculator')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCourse,
        backgroundColor: const Color(0xFFfdcb6e),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Course',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [

            // ── GPA Display Card ──────────────────────────
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFfdcb6e), Color(0xFFe17055)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFfdcb6e).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 55,
                      lineWidth: 8,
                      percent: (_gpa / 4.0).clamp(0.0, 1.0),
                      center: Text(
                        _gpa.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current GPA',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(status['label'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('${_courses.length} courses added',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Grade Scale Reference ──────────────────────
            FadeInUp(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Grade Scale (4.0)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _gradePoints.entries.map((e) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfdcb6e).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${e.key}: ${e.value}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFe17055))),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Course List ────────────────────────────────
            if (_courses.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('My Courses',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ..._courses.asMap().entries.map((e) {
                final i = e.key;
                final c = e.value;
                return FadeInUp(
                  delay: Duration(milliseconds: i * 80),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFfdcb6e), Color(0xFFe17055)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(c['grade'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                      title: Text(c['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          '${c['credits']} credits  •  ${_gradePoints[c['grade']]} points'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: () =>
                            setState(() => _courses.removeAt(i)),
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
}