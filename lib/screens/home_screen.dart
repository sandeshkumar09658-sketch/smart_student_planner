import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../database/db_helper.dart';
import 'tasks_screen.dart';
import 'attendance_screen.dart';
import 'planner_screen.dart';
import 'progress_screen.dart';
import 'login_screen.dart';

/// Home screen - main dashboard of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _studentName = '';
  String _rollNumber = '';
  int _taskCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load student info and task stats
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await DBHelper.getTasks();
    setState(() {
      _studentName = prefs.getString('student_name') ?? 'Student';
      _rollNumber  = prefs.getString('roll_number')  ?? '';
      _taskCount   = tasks.length;
      _completedCount = tasks.where((t) => t.isCompleted).length;
    });
  }

  /// Logout - clear saved data
 Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Dark/Light mode toggle
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: themeNotifier.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Greeting Card ──────────────────────────────
              FadeInDown(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFF9C88FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, $_studentName! 👋',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      Text('Roll No: $_rollNumber',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _statChip('$_taskCount Tasks', Icons.task_alt),
                          const SizedBox(width: 10),
                          _statChip('$_completedCount Done', Icons.check_circle),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Quick Access',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // ── Feature Grid ───────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  FadeInLeft(delay: const Duration(milliseconds: 100),
                    child: _featureCard(context, 'My Tasks', Icons.task_rounded,
                        const Color(0xFF6C63FF), const TasksScreen())),
                  FadeInRight(delay: const Duration(milliseconds: 200),
                    child: _featureCard(context, 'Attendance', Icons.co_present_rounded,
                        const Color(0xFF00D2D3), const AttendanceScreen())),
                  FadeInLeft(delay: const Duration(milliseconds: 300),
                    child: _featureCard(context, 'Study Planner', Icons.calendar_month_rounded,
                        const Color(0xFFFF6B6B), const PlannerScreen())),
                  FadeInRight(delay: const Duration(milliseconds: 400),
                    child: _featureCard(context, 'Progress', Icons.bar_chart_rounded,
                        const Color(0xFF26de81), const ProgressScreen())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Small white chip for stats on greeting card
  Widget _statChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  /// Feature card for navigating to each section
  Widget _featureCard(BuildContext context, String title, IconData icon,
      Color color, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => screen))
          .then((_) => _loadData()),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15, color: color)),
          ],
        ),
      ),
    );
  }
}