import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/core/constants/app_constants.dart';
import 'package:focus_companion/core/routing/app_router.dart';
import 'package:focus_companion/features/tasks/domain/entities/task.dart';
import 'package:focus_companion/features/tasks/data/providers/task_providers.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String? taskId;

  const TaskDetailScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _loadTask();
    }
  }

  Future<void> _loadTask() async {
    final task = await ref.read(taskByIdProvider(widget.taskId!).future);
    if (task != null && mounted) {
      setState(() {
        _titleController.text = task.title;
        _descriptionController.text = task.description ?? '';
        _selectedPriority = task.priority;
        _selectedDueDate = task.dueDate;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(taskRepositoryProvider);

      if (widget.taskId != null) {
        // Update existing task
        final existingTask = await repo.getTaskById(widget.taskId!);
        if (existingTask != null && existingTask.title.isNotEmpty) {
          final updatedTask = existingTask.copyWith(
            title: _titleController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            priority: _selectedPriority,
            dueDate: _selectedDueDate,
          );
          await repo.updateTask(updatedTask);
        }
      } else {
        // Create new task
        final newTask = Task(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
        );
        await repo.createTask(newTask);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.taskId != null
                  ? 'อัปเดตงานเรียบร้อย'
                  : 'เพิ่มงานเรียบร้อย',
            ),
          ),
        );
        AppRouter.goBack(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId != null ? 'แก้ไขงาน' : 'เพิ่มงานใหม่'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveTask,
              tooltip: 'บันทึกงาน',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Title Field
            _buildFieldHeader(theme, 'ชื่องาน *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'ระบุชื่องาน',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุชื่องาน';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Description Field
            _buildFieldHeader(theme, 'รายละเอียด'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'ระบุรายละเอียดงาน (ถ้ามี)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),

            // Priority Selector
            _buildFieldHeader(theme, 'ระดับความสำคัญ'),
            const SizedBox(height: 12),
            SegmentedButton<Priority>(
              segments: const [
                ButtonSegment(value: Priority.low, label: Text('ต่ำ')),
                ButtonSegment(value: Priority.medium, label: Text('ปานกลาง')),
                ButtonSegment(value: Priority.high, label: Text('สูง')),
              ],
              selected: {_selectedPriority},
              onSelectionChanged: (Set<Priority> selected) {
                setState(() => _selectedPriority = selected.first);
              },
            ),
            const SizedBox(height: 32),

            // Due Date Selector
            _buildFieldHeader(theme, 'วันครบกำหนด'),
            const SizedBox(height: 12),
            ListTile(
              tileColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              leading: Icon(Icons.event, color: theme.colorScheme.primary),
              title: Text(
                _selectedDueDate != null
                    ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                    : 'ไม่ได้กำหนด',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _selectedDueDate != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              trailing: _selectedDueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _selectedDueDate = null);
                      },
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _selectDueDate,
            ),

            const SizedBox(height: 48),

            // Save Button (Mission Initiate)
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                widget.taskId != null ? 'บันทึกการแก้ไข' : 'เพิ่มงาน',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary.withOpacity(0.7),
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
