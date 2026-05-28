import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../models/task_model.dart';
import '../../../services/deadline_service.dart';
import '../../widgets/confetti_overlay.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskRepository.getTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  DeadlineUrgency _getUrgency(String dateStr) {
    try {
      final date = DateFormat('dd MMM yyyy').parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dueDay = DateTime(date.year, date.month, date.day);
      final days = dueDay.difference(today).inDays;

      if (days < 0) return DeadlineUrgency.overdue;
      if (days == 0) return DeadlineUrgency.today;
      if (days == 1) return DeadlineUrgency.tomorrow;
      if (days <= 3) return DeadlineUrgency.soon;
      if (days <= 7) return DeadlineUrgency.week;
      return DeadlineUrgency.far;
    } catch (_) {
      return DeadlineUrgency.far;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiOverlay(
      show: _showConfetti,
      onComplete: () => setState(() => _showConfetti = false),
      child: Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {},
            tooltip: 'View Calendar',
          ),
        ],
      ),
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const ShimmerWidget(width: 100, height: 22),
                  const SizedBox(height: 16),
                  const ShimmerCard(),
                  const ShimmerCard(),
                  const ShimmerCard(),
                ],
              ),
            )
          : _tasks.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildSection(
                        title: 'Overdue',
                        color: AppColors.urgent,
                        tasks: _tasks
                            .where((t) => _getUrgency(t.dueDate) == DeadlineUrgency.overdue)
                            .toList(),
                      ),
                      _buildSection(
                        title: 'Due Today',
                        color: AppColors.warning,
                        tasks: _tasks
                            .where((t) => _getUrgency(t.dueDate) == DeadlineUrgency.today)
                            .toList(),
                      ),
                      _buildSection(
                        title: 'This Week',
                        color: AppColors.calm,
                        tasks: _tasks.where((t) {
                          final u = _getUrgency(t.dueDate);
                          return u == DeadlineUrgency.tomorrow ||
                              u == DeadlineUrgency.soon ||
                              u == DeadlineUrgency.week;
                        }).toList(),
                      ),
                      _buildSection(
                        title: 'Later',
                        color: AppColors.done,
                        tasks: _tasks
                            .where((t) => _getUrgency(t.dueDate) == DeadlineUrgency.far)
                            .toList(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.task_alt_rounded, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first task',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color color,
    required List<TaskModel> tasks,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: SectionHeader(
            title: title,
            subtitle: '${tasks.length} task${tasks.length == 1 ? '' : 's'}',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${tasks.length}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'All done! ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                  const Icon(Icons.celebration_outlined, color: AppColors.warning, size: 20),
                ],
              ),
            ),
          )
        else
          ...tasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    DateTime? parsedDate;
    try {
      parsedDate = DateFormat('dd MMM yyyy').parse(task.dueDate);
    } catch (_) {}

    int diff = 0;
    bool isOverdue = false;
    if (parsedDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      diff = due.difference(today).inDays;
      isOverdue = due.isBefore(today);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(task.id ?? task.hashCode),
        direction: DismissDirection.horizontal,
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.done,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 28),
          child: const Icon(Icons.check_circle_outline_rounded,
              color: Colors.white, size: 28),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: AppColors.urgent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 28),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.white, size: 28),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
          HapticFeedback.mediumImpact();
          await TaskRepository.toggleComplete(task.id!);
          if (task.isCompleted) {
            await ProgressRepository.markDayActive();
            setState(() => _showConfetti = true);
          }
          _loadTasks();
            return false;
          }
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Delete Task'),
              content: Text('Remove "${task.title}" permanently?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Delete',
                      style: TextStyle(color: AppColors.urgent)),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await TaskRepository.deleteTask(task.id!);
            _loadTasks();
          }
          return confirmed ?? false;
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: task.isCompleted ? 0.55 : 1.0,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await TaskRepository.toggleComplete(task.id!);
                    if (task.isCompleted) {
                      await ProgressRepository.markDayActive();
                      setState(() => _showConfetti = true);
                    }
                    _loadTasks();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppColors.primary
                            : isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white)
                        : null,
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
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.subject,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white60
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            task.dueDate,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.priority == 3
                            ? AppColors.urgent
                            : task.priority == 2
                                ? AppColors.warning
                                : AppColors.done,
                        boxShadow: [
                          BoxShadow(
                            color: (task.priority == 3
                                    ? AppColors.urgent
                                    : task.priority == 2
                                        ? AppColors.warning
                                        : AppColors.done)
                                .withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOverdue
                          ? '${diff.abs()}d ago'
                          : diff == 0
                              ? 'Today'
                              : diff == 1
                                  ? 'Tomorrow'
                                  : '${diff}d',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isOverdue
                            ? AppColors.urgent
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskSheet() {
    final titleCtrl = TextEditingController();
    String? sheetError;
    int selectedPriority = 2;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    const subjects = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Science',
      'Literature',
      'History',
      'Computer Science',
      'Art',
      'Music',
      'Physical Education',
      'Extracurricular',
    ];
    String selectedSubject = subjects.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark =
                Theme.of(context).brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white30
                              : Colors.black26,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Add New Task',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: titleCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter task name...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSubject,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                      ),
                      items: subjects
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setSheetState(() => selectedSubject = v);
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    const Text('Priority',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _PriorityChip(
                          label: 'Low',
                          color: AppColors.done,
                          selected: selectedPriority == 1,
                          onTap: () =>
                              setSheetState(() => selectedPriority = 1),
                        ),
                        const SizedBox(width: 10),
                        _PriorityChip(
                          label: 'Medium',
                          color: AppColors.warning,
                          selected: selectedPriority == 2,
                          onTap: () =>
                              setSheetState(() => selectedPriority = 2),
                        ),
                        const SizedBox(width: 10),
                        _PriorityChip(
                          label: 'High',
                          color: AppColors.urgent,
                          selected: selectedPriority == 3,
                          onTap: () =>
                              setSheetState(() => selectedPriority = 3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: Theme.of(context)
                                          .colorScheme
                                          .copyWith(
                                            primary: AppColors.primary,
                                          ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setSheetState(() => selectedDate = picked);
                              }
                            },
                            icon: const Icon(
                                Icons.calendar_today_rounded,
                                size: 18),
                            label: Text(
                              DateFormat('MMM d, yyyy')
                                  .format(selectedDate),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (sheetError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.urgent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.urgent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.urgent, size: 20),
                              const SizedBox(width: 10),
                              Text(sheetError!, style: const TextStyle(color: AppColors.urgent, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setSheetState(() => sheetError = null);
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) {
                            setSheetState(() => sheetError = 'Please enter a task title');
                            return;
                          }
                          final newTask = TaskModel(
                            title: titleCtrl.text.trim(),
                            subject: selectedSubject,
                            dueDate: DateFormat('dd MMM yyyy').format(selectedDate),
                            priority: selectedPriority,
                          );
                          await TaskRepository.addTask(newTask);
                          _loadTasks();
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add Task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color
                : isDark
                    ? Colors.white24
                    : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? color : null,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
