import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

/// Tasks screen - Add, view, complete, and delete tasks
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// Load all tasks from database
  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await DBHelper.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  /// Show dialog to add a new task
  void _showAddTaskDialog() {
    final titleCtrl   = TextEditingController();
    final subjectCtrl = TextEditingController();
    int priority      = 1;
    DateTime dueDate  = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
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
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Add New Task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Title field
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  prefixIcon: const Icon(Icons.task_alt, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Subject field
              TextField(
                controller: subjectCtrl,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: const Icon(Icons.book_rounded, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Priority selector
              const Text('Priority:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _priorityChip('Low',    1, priority, (v) => setModalState(() => priority = v)),
                  const SizedBox(width: 8),
                  _priorityChip('Medium', 2, priority, (v) => setModalState(() => priority = v)),
                  const SizedBox(width: 8),
                  _priorityChip('High',   3, priority, (v) => setModalState(() => priority = v)),
                ],
              ),
              const SizedBox(height: 12),

              // Due date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                title: Text('Due: ${DateFormat('dd MMM yyyy').format(dueDate)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setModalState(() => dueDate = picked);
                },
              ),
              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty || subjectCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields!')),
                      );
                      return;
                    }
                    await DBHelper.insertTask(TaskModel(
                      title:    titleCtrl.text.trim(),
                      subject:  subjectCtrl.text.trim(),
                      dueDate:  DateFormat('dd MMM yyyy').format(dueDate),
                      priority: priority,
                    ));
                    if (!mounted) return;
                    Navigator.pop(context);
                    _loadTasks();
                  },
                  child: const Text('Save Task',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Priority chip widget
  Widget _priorityChip(String label, int value, int selected, Function(int) onTap) {
    final colors = {1: Colors.green, 2: Colors.orange, 3: Colors.red};
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors[value] : colors[value]!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors[value]!),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : colors[value],
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  /// Priority label for task card
  Widget _priorityBadge(int priority) {
    final labels = {1: 'Low', 2: 'Medium', 3: 'High'};
    final colors = {1: Colors.green, 2: Colors.orange, 3: Colors.red};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: colors[priority]!.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(labels[priority]!,
          style: TextStyle(
              color: colors[priority], fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 80,
                          color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No tasks yet!',
                          style: TextStyle(color: Colors.grey.shade400,
                              fontSize: 18)),
                      const Text('Tap + to add your first task',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: _tasks.length,
                  itemBuilder: (ctx, i) {
                    final task = _tasks[i];
                    return FadeInUp(
                      delay: Duration(milliseconds: i * 80),
                      child: Dismissible(
                        key: Key(task.id.toString()),
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
                          await DBHelper.deleteTask(task.id!);
                          _loadTasks();
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Checkbox(
                              value: task.isCompleted,
                              activeColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              onChanged: (val) async {
                                task.isCompleted = val!;
                                await DBHelper.updateTask(task);
                                _loadTasks();
                              },
                            ),
                            title: Text(task.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.isCompleted
                                        ? Colors.grey
                                        : null)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.subject,
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.calendar_today,
                                      size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(task.dueDate,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                  const SizedBox(width: 8),
                                  _priorityBadge(task.priority),
                                ]),
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