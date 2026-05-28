import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/study_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../models/task_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';
import 'ai_chat_screen.dart';

class StudyTab extends StatefulWidget {
  const StudyTab({super.key});

  @override
  State<StudyTab> createState() => _StudyTabState();
}

class _StudyTabState extends State<StudyTab> {
  TimerMode _currentMode = TimerMode.focus;
  int _remainingSeconds = 25 * 60;
  final int _currentSession = 2;
  final int _totalSessions = 4;
  bool _isRunning = false;
  Timer? _timer;

  final TextEditingController _aiController = TextEditingController();
  final String _aiResponse = 'Ask me anything about your studies!';

  List<TaskModel> _todaysTasks = [];
  bool _isLoadingTasks = true;

  static const int _focusDuration = 25 * 60;
  static const int _shortBreakDuration = 5 * 60;
  static const int _longBreakDuration = 15 * 60;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _focusDuration;
    _loadTodaysPlan();
  }

  Future<void> _loadTodaysPlan() async {
    setState(() => _isLoadingTasks = true);
    final tasks = await TaskRepository.getTasks();
    setState(() {
      _todaysTasks = tasks.where((t) => !t.isCompleted).toList();
      _isLoadingTasks = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _aiController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _onTimerEnd();
      }
    });
    setState(() => _isRunning = true);
  }

  void _onTimerEnd() {
    if (_currentMode == TimerMode.focus) {
      StudyRepository.addFocusMinutes(25);
    }
    _showCompletionSnackbar();
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _getDurationForMode(_currentMode);
    });
  }

  void _skipTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _isRunning = false;
    });
    _onTimerEnd();
  }

  int _getDurationForMode(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return _focusDuration;
      case TimerMode.shortBreak:
        return _shortBreakDuration;
      case TimerMode.longBreak:
        return _longBreakDuration;
    }
  }

  void _switchMode(TimerMode mode) {
    _timer?.cancel();
    setState(() {
      _currentMode = mode;
      _isRunning = false;
      _remainingSeconds = _getDurationForMode(mode);
    });
  }

  void _showCompletionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.celebration_outlined, color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            const Text('Session Complete!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = _getDurationForMode(_currentMode);
    if (total == 0) return 0;
    return _remainingSeconds / total;
  }

  String get _modeLabel {
    switch (_currentMode) {
      case TimerMode.focus:
        return 'Focus';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Hub'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.bgDark, AppColors.surfaceDark]
                : [AppColors.bgLight, AppColors.surfaceLight],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadTodaysPlan,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildPomodoroTimer(isDark),
                  const SizedBox(height: 24),
                  _buildStudyPlan(isDark),
                  const SizedBox(height: 24),
                  _buildAiAssistant(isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPomodoroTimer(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            _buildModePill(TimerMode.focus, 'Focus', isDark),
            const SizedBox(width: 8),
            _buildModePill(TimerMode.shortBreak, 'Short Break', isDark),
            const SizedBox(width: 8),
            _buildModePill(TimerMode.longBreak, 'Long Break', isDark),
          ],
        ),
        const SizedBox(height: 24),
        CircularPercentIndicator(
          radius: 100,
          lineWidth: 10,
          percent: _progress,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _modeLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          progressColor: AppColors.primary,
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _resetTimer,
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.textSecondary,
              iconSize: 28,
            ),
            const SizedBox(width: 24),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                icon: Icon(
                  _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
                iconSize: 36,
                constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: _skipTimer,
              icon: const Icon(Icons.skip_next_rounded),
              color: AppColors.textSecondary,
              iconSize: 28,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Session $_currentSession of $_totalSessions',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            ...List.generate(_totalSessions, (i) {
              final isActive = i < _currentSession;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.primary
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1)),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildModePill(TimerMode mode, String label, bool isDark) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudyPlan(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Today's Plan", padding: EdgeInsets.zero),
        const SizedBox(height: 12),
        if (_isLoadingTasks)
          const Column(
            children: [
              ShimmerCard(),
              SizedBox(height: 8),
              ShimmerCard(),
            ],
          )
        else if (_todaysTasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'All tasks complete! Take a break.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ..._todaysTasks.take(4).map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.subject,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.assignment_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    task.dueDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildAiAssistant(bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen())),
      child: GlassCard(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Need help?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _aiResponse,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _aiController,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tap to open AI chat...',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiChatScreen()),
                    );
                  },
                  icon: const Icon(Icons.open_in_full_rounded, color: Colors.white, size: 20),
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

enum TimerMode { focus, shortBreak, longBreak }
