import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/study_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../models/task_model.dart';
import '../../../services/deadline_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';
import '../study/ai_chat_screen.dart';
import '../study/study_screen.dart';
import '../tasks/tasks_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    TasksTab(),
    StudyTab(),
    ProgressTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.glassBorderDark
                : AppColors.glassBorderLight,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded), label: 'Study'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Home Tab – Dashboard
// ──────────────────────────────────────────────────────────────

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _studentName = 'Student';
  String _greeting = '';
  int _streak = 0;
  int _focusMinutes = 0;
  int _pendingTasks = 0;
  int _completedTasks = 0;
  double _attendance = 0;
  DeadlineTask? _nextDeadline;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _loadData();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = await TaskRepository.getTasks();
    final tasks = taskList;
    final deadlines = await DeadlineService.getDeadlineTasks();
    final streak = await ProgressRepository.getCurrentStreak();
    final focusMins = await StudyRepository.getTodayFocusMinutes();
    final attPct = await AttendanceRepository.getOverallPercentage();

    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    if (!mounted) return;
    setState(() {
      _studentName = prefs.getString('student_name') ?? 'Student';
      _streak = streak;
      _focusMinutes = focusMins;
      _pendingTasks = pending.length;
      _completedTasks = completed.length;
      _attendance = attPct;
      _nextDeadline = deadlines.isNotEmpty ? deadlines.first : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const ShimmerWidget(width: 180, height: 24),
              const SizedBox(height: 16),
              const ShimmerWidget(width: double.infinity, height: 120),
              const SizedBox(height: 20),
              const ShimmerCard(),
              const ShimmerCard(),
              const ShimmerCard(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _AppBarArea(greeting: _greeting, studentName: _studentName),
              const SizedBox(height: 20),
              _StreakBadge(streak: _streak),
              const SizedBox(height: 16),
              _DeadlineCard(deadline: _nextDeadline),
              const SizedBox(height: 20),
              _QuickStatsRow(
                focusMinutes: _focusMinutes,
                completedTasks: _completedTasks,
                pendingTasks: _pendingTasks,
                attendance: _attendance,
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Quick Actions', padding: const EdgeInsets.only(bottom: 12)),
              const _QuickActionsGrid(),
              const SizedBox(height: 24),
              SectionHeader(title: "Today's Schedule", padding: const EdgeInsets.only(bottom: 12)),
              _ScheduleList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Sub-widgets
// ──────────────────────────────────────────────────────────────

class _AppBarArea extends StatelessWidget {
  final String greeting;
  final String studentName;

  const _AppBarArea({required this.greeting, required this.studentName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $studentName',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Let\'s make today productive',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_rounded, size: 22),
            color: isDark ? Colors.white70 : AppColors.textSecondary,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      gradient: AppColors.streakGradient,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.local_fire_department, color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                streak == 0 ? 'Start your streak today!' : '$streak Day Streak',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              if (streak > 0) ...[
                const SizedBox(height: 2),
                Text(
                  'Keep the momentum going!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final DeadlineTask? deadline;

  const _DeadlineCard({this.deadline});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: AppColors.accentGradient,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: Colors.white.withValues(alpha: 0.9), size: 20),
              const SizedBox(width: 8),
              Text(
                'Upcoming Deadline',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (deadline != null) ...[
            Text(
              '${deadline!.task.title} - ${deadline!.label}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              deadline!.task.subject,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
            ),
          ] else ...[
            Text(
              'No pending deadlines!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          if (deadline != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                label: const Text('View All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final int focusMinutes;
  final int completedTasks;
  final int pendingTasks;
  final double attendance;

  const _QuickStatsRow({
    required this.focusMinutes,
    required this.completedTasks,
    required this.pendingTasks,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.timer_rounded, label: 'Focus Score', value: '$focusMinutes min today')),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(icon: Icons.check_box_rounded, label: 'Tasks Done', value: '$completedTasks/$pendingTasks')),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(icon: Icons.percent_rounded, label: 'Attendance', value: '${attendance.toStringAsFixed(0)}%')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(icon: Icons.track_changes_rounded, label: 'Start Focus', onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyTab()));
      }),
      _ActionData(icon: Icons.edit_note_rounded, label: 'Add Task', onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksTab()));
      }),
      _ActionData(icon: Icons.calendar_month_rounded, label: 'View Planner', onTap: () {}),
      _ActionData(
        icon: Icons.smart_toy_rounded, label: 'AI Help',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen())),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionButton(icon: action.icon, label: action.label, onTap: action.onTap);
      },
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionData({required this.icon, required this.label, required this.onTap});
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TaskModel>>(
      future: TaskRepository.getTasks(),
      builder: (context, snapshot) {
        final tasks = (snapshot.data ?? []).where((t) => !t.isCompleted).toList();
        if (tasks.isEmpty) {
          return GlassCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No pending tasks. Enjoy your free time!',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }
        return Column(
          children: tasks.take(4).map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TaskScheduleCard(task: task),
          )).toList(),
        );
      },
    );
  }
}

class _TaskScheduleCard extends StatelessWidget {
  final TaskModel task;

  const _TaskScheduleCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color urgencyColor;
    if (task.priority == 3) {
      urgencyColor = AppColors.urgent;
    } else if (task.priority == 2) {
      urgencyColor = AppColors.warning;
    } else {
      urgencyColor = AppColors.done;
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.school_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: urgencyColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.subject,
              style: TextStyle(
                fontSize: 12,
                color: urgencyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
