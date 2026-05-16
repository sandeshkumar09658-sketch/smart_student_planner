import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../database/db_helper.dart';
import 'tasks_screen.dart';
import 'attendance_screen.dart';
import 'planner_screen.dart';
import 'progress_screen.dart';
import 'ai_assistant_screen.dart';
import 'gpa_screen.dart';
import 'timetable_screen.dart';
import 'pomodoro_screen.dart';
import 'login_screen.dart';

/// Home dashboard - main hub of the Smart Student Planner
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _studentName = '';
  String _rollNumber  = '';
  int _taskCount      = 0;
  int _completedCount = 0;
  String _greeting    = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _setGreeting();
  }

  /// Set greeting based on time of day
  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12)       _greeting = 'Good Morning';
    else if (hour < 17)  _greeting = 'Good Afternoon';
    else                 _greeting = 'Good Evening';
  }

  /// Load student info and task statistics
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await DBHelper.getTasks();
    setState(() {
      _studentName    = prefs.getString('student_name') ?? 'Student';
      _rollNumber     = prefs.getString('roll_number')  ?? '';
      _taskCount      = tasks.length;
      _completedCount = tasks.where((t) => t.isCompleted).length;
    });
  }

  /// Logout and go back to login screen
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
    final today = DateFormat('EEEE, dd MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F0FF),
      appBar: AppBar(
        title: const Text('Smart Planner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: themeNotifier.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Greeting Banner ─────────────────────────────
              FadeInDown(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(today,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('$_greeting, $_studentName! 👋',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      Text('Roll: $_rollNumber',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(children: [
                        _statBubble(Icons.task_alt, '$_taskCount', 'Tasks'),
                        const SizedBox(width: 10),
                        _statBubble(Icons.check_circle, '$_completedCount', 'Done'),
                        const SizedBox(width: 10),
                        _statBubble(Icons.pending_actions,
                            '${_taskCount - _completedCount}', 'Pending'),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Core Features ───────────────────────────────
              _sectionTitle('Core Features'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  FadeInLeft(delay: const Duration(milliseconds: 100),
                    child: _featureCard('My Tasks',
                        Icons.task_rounded,
                        'Add & manage assignments',
                        const Color(0xFF6C63FF),
                        const Color(0xFF9C88FF),
                        const TasksScreen())),
                  FadeInRight(delay: const Duration(milliseconds: 150),
                    child: _featureCard('Attendance',
                        Icons.co_present_rounded,
                        'Track class attendance',
                        const Color(0xFF00D2D3),
                        const Color(0xFF00F5D4),
                        const AttendanceScreen())),
                  FadeInLeft(delay: const Duration(milliseconds: 200),
                    child: _featureCard('Study Planner',
                        Icons.calendar_month_rounded,
                        'Plan your study sessions',
                        const Color(0xFFFF6B6B),
                        const Color(0xFFFF8E53),
                        const PlannerScreen())),
                  FadeInRight(delay: const Duration(milliseconds: 250),
                    child: _featureCard('Progress',
                        Icons.bar_chart_rounded,
                        'View academic progress',
                        const Color(0xFF26de81),
                        const Color(0xFF20bf6b),
                        const ProgressScreen())),
                ],
              ),
              const SizedBox(height: 24),

              // ── Advanced Features ───────────────────────────
              _sectionTitle('Advanced Features ⚡'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  FadeInLeft(delay: const Duration(milliseconds: 300),
                    child: _featureCard('AI Assistant',
                        Icons.psychology_rounded,
                        'Chat with AI for help',
                        const Color(0xFFa29bfe),
                        const Color(0xFF6c5ce7),
                        const AiAssistantScreen())),
                  FadeInRight(delay: const Duration(milliseconds: 350),
                    child: _featureCard('GPA Calculator',
                        Icons.calculate_rounded,
                        'Calculate your grades',
                        const Color(0xFFfdcb6e),
                        const Color(0xFFe17055),
                        const GpaScreen())),
                  FadeInLeft(delay: const Duration(milliseconds: 400),
                    child: _featureCard('Timetable',
                        Icons.table_chart_rounded,
                        'View class schedule',
                        const Color(0xFF74b9ff),
                        const Color(0xFF0984e3),
                        const TimetableScreen())),
                  FadeInRight(delay: const Duration(milliseconds: 450),
                    child: _featureCard('Pomodoro Timer',
                        Icons.timer_rounded,
                        'Focus & study timer',
                        const Color(0xFFff7675),
                        const Color(0xFFd63031),
                        const PomodoroScreen())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section title widget
  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  /// Stat bubble for greeting banner
  Widget _statBubble(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ]),
      ]),
    );
  }

  /// Feature card widget with gradient
  Widget _featureCard(String title, IconData icon, String subtitle,
      Color color1, Color color2, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => screen))
          .then((_) => _loadData()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1.withOpacity(0.15), color2.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color1.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color1, color2]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color1)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11,
                    color: color1.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}