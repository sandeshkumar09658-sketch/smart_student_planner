import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/study_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../models/attendance_model.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  int _completedTasks = 0;
  int _totalTasks = 0;
  double _gpa = 0.0;

  Map<String, int> _weekMinutes = {};
  List<AttendanceModel> _attendanceRecords = [];
  List<Map> _courses = [];
  List<Map> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await TaskRepository.getTasks();
    final weekMins = await StudyRepository.getWeekMinutes();
    final gpa = await ProgressRepository.getGpa();
    final attendance = await AttendanceRepository.getAll();
    final courses = await ProgressRepository.getCourses();
    final achievements = await ProgressRepository.getAchievements();

    if (!mounted) return;
    setState(() {
      _completedTasks = tasks.where((t) => t.isCompleted).length;
      _totalTasks = tasks.length;
      _weekMinutes = weekMins;
      _gpa = gpa;
      _attendanceRecords = attendance;
      _courses = courses;
      _achievements = achievements;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const ShimmerWidget(width: 160, height: 22),
                  const SizedBox(height: 16),
                  const ShimmerWidget(width: double.infinity, height: 100),
                  const SizedBox(height: 20),
                  const ShimmerCard(),
                  const ShimmerCard(),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    SectionHeader(
                      title: 'Weekly Overview',
                      subtitle: 'Focus minutes this week',
                      padding: const EdgeInsets.only(bottom: 16),
                    ),
                    _buildWeeklyChart(isDark),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Task Completion',
                      padding: const EdgeInsets.only(bottom: 16),
                    ),
                    _buildTaskCompletion(isDark),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Subject Attendance',
                      padding: EdgeInsets.only(bottom: 16),
                    ),
                    if (_attendanceRecords.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No attendance records yet.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textHint
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._attendanceRecords.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildAttendanceCard(a, isDark),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const SectionHeader(
                      title: 'GPA Overview',
                      padding: EdgeInsets.only(bottom: 16),
                    ),
                    _buildGpaCard(isDark),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Achievements',
                      padding: EdgeInsets.only(bottom: 16),
                    ),
                    _buildAchievementsGrid(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWeeklyChart(bool isDark) {
    final dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final shortLabels = {
      'Mon': 'M', 'Tue': 'T', 'Wed': 'W', 'Thu': 'T',
      'Fri': 'F', 'Sat': 'S', 'Sun': 'S',
    };
    final values = dayOrder.map((d) => _weekMinutes[d] ?? 0).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
    final todayIndex = DateTime.now().weekday - 1;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final value = values[i].toDouble();
            final heightFraction = maxVal > 0 ? value / maxVal : 0.0;
            final isToday = i == todayIndex;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 4,
                  right: i == 6 ? 0 : 4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      height: heightFraction * 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: isToday
                            ? const LinearGradient(
                                colors: [
                                  AppColors.accent,
                                  AppColors.accentLight,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: (isToday
                                    ? AppColors.accent
                                    : AppColors.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      shortLabels[dayOrder[i]]!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday
                            ? (isDark
                                ? AppColors.accentLight
                                : AppColors.accent)
                            : (isDark
                                ? AppColors.textHint
                                : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTaskCompletion(bool isDark) {
    final percent = _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? AppColors.textHint : AppColors.textSecondary;

    return GlassCard(
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 48,
            lineWidth: 10,
            percent: percent,
            center: Text(
              '${(percent * 100).toInt()}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Completion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(percent * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_completedTasks of $_totalTasks tasks done',
                  style: TextStyle(
                    fontSize: 13,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceModel record, bool isDark) {
    final percent =
        record.totalClasses > 0 ? record.attended / record.totalClasses : 0.0;
    final Color barColor;
    if (percent >= 0.85) {
      barColor = AppColors.done;
    } else if (percent >= 0.70) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.urgent;
    }
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.subject,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${record.attended}/${record.totalClasses}',
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: barColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpaCard(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor =
        isDark ? AppColors.textHint : AppColors.textSecondary;

    final gradeCounts = <String, int>{};
    for (final c in _courses) {
      final grade = (c['grade'] as String?) ?? '';
      final firstLetter = grade.isNotEmpty ? grade[0] : '?';
      gradeCounts[firstLetter] = (gradeCounts[firstLetter] ?? 0) + 1;
    }
    final sortedGrades = gradeCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final gpaMessage = _gpa >= 3.5
        ? 'Excellent!'
        : _gpa >= 2.5
            ? 'Good!'
            : _gpa >= 1.5
                ? 'Keep trying!'
                : 'Needs improvement';

    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current GPA',
                  style: TextStyle(
                    fontSize: 13,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _gpa.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gpaMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (sortedGrades.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sortedGrades.map((entry) {
                Color gradeColor;
                switch (entry.key) {
                  case 'A':
                    gradeColor = AppColors.done;
                    break;
                  case 'B':
                    gradeColor = AppColors.calm;
                    break;
                  default:
                    gradeColor = AppColors.warning;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: gradeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: gradeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'x${entry.value}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final a = _achievements[index];
        final title = a['title'] as String? ?? '';
        final iconStr = a['icon'] as String? ?? 'star';
        final unlocked = a['unlockedAt'] != null;
        final iconData = _mapAchievementIcon(iconStr);
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 28,
                color: unlocked ? AppColors.warning : Colors.grey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: unlocked
                      ? textColor
                      : (isDark
                          ? Colors.grey.shade500
                          : AppColors.textHint),
                ),
              ),
              const SizedBox(height: 6),
              Icon(
                unlocked
                    ? Icons.lock_open_rounded
                    : Icons.lock_rounded,
                size: 14,
                color: unlocked
                    ? AppColors.warning
                    : (isDark
                        ? Colors.grey.shade600
                        : AppColors.textHint),
              ),
              if (unlocked)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static IconData _mapAchievementIcon(String icon) {
    switch (icon) {
      case 'star': return Icons.grade_rounded;
      case 'rocket': return Icons.rocket_launch_rounded;
      case 'brain': return Icons.psychology_rounded;
      case 'fire': return Icons.local_fire_department_rounded;
      case 'trophy': return Icons.emoji_events_rounded;
      case 'book': return Icons.menu_book_rounded;
      case 'trend': return Icons.trending_up_rounded;
      case 'target': return Icons.track_changes_rounded;
      case 'timer': return Icons.timer_rounded;
      case 'medal': return Icons.military_tech_rounded;
      case 'check': return Icons.verified_rounded;
      case 'bolt': return Icons.bolt_rounded;
      case 'school': return Icons.school_rounded;
      case 'coffee': return Icons.coffee_rounded;
      case 'lightbulb': return Icons.lightbulb_rounded;
      default: return Icons.star_rounded;
    }
  }
}
