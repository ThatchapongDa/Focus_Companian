import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_companion/core/constants/app_constants.dart';
import 'package:focus_companion/core/database/hive_service.dart';
import 'package:focus_companion/features/tasks/domain/entities/task.dart';
import 'package:focus_companion/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final HiveService _hiveService;
  Box<Task>? _taskBox;

  TaskRepositoryImpl(this._hiveService);

  Future<Box<Task>> get _box async {
    if (_taskBox != null && _taskBox!.isOpen) {
      return _taskBox!;
    }
    _taskBox = await _hiveService.openBox<Task>(AppConstants.tasksBoxName);
    return _taskBox!;
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final box = await _box;
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final box = await _box;
    return box.values.firstWhere(
      (task) => task.id == id,
      orElse: () => Task(title: ''), // Will be null-checked
    );
  }

  @override
  Future<List<Task>> getTodayTasks() async {
    final box = await _box;
    final now = DateTime.now();
    return box.values.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == now.year &&
          task.dueDate!.month == now.month &&
          task.dueDate!.day == now.day;
    }).toList()..sort((a, b) => b.priorityValue.compareTo(a.priorityValue));
  }

  @override
  Future<List<Task>> getTasksByCategory(String categoryId) async {
    final box = await _box;
    return box.values.where((task) => task.categoryId == categoryId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Task>> getIncompleteTasks() async {
    final box = await _box;
    return box.values.where((task) => !task.isCompleted).toList()
      ..sort((a, b) => b.priorityValue.compareTo(a.priorityValue));
  }

  @override
  Future<void> createTask(Task task) async {
    final box = await _box;
    await box.put(task.id, task);
  }

  @override
  Future<void> updateTask(Task task) async {
    final box = await _box;
    task.updatedAt = DateTime.now();
    await box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<void> toggleComplete(String id) async {
    final task = await getTaskById(id);
    if (task != null && task.title.isNotEmpty) {
      task.isCompleted = !task.isCompleted;
      task.updatedAt = DateTime.now();
      await updateTask(task);
    }
  }

  @override
  Future<void> addFocusMinutes(String id, int minutes) async {
    final task = await getTaskById(id);
    if (task != null && task.title.isNotEmpty) {
      task.totalFocusMinutes += minutes;
      task.updatedAt = DateTime.now();
      await updateTask(task);
    }
  }

  @override
  Stream<List<Task>> watchAllTasks() async* {
    final box = await _box;
    yield box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await for (final _ in box.watch()) {
      yield box.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  @override
  Stream<List<Task>> watchTodayTasks() async* {
    final box = await _box;
    final now = DateTime.now();

    List<Task> filterTodayTasks() {
      return box.values.where((task) {
        if (task.dueDate == null) return false;
        return task.dueDate!.year == now.year &&
            task.dueDate!.month == now.month &&
            task.dueDate!.day == now.day;
      }).toList()..sort((a, b) => b.priorityValue.compareTo(a.priorityValue));
    }

    yield filterTodayTasks();

    await for (final _ in box.watch()) {
      yield filterTodayTasks();
    }
  }
}
