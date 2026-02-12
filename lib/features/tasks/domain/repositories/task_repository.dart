import 'package:focus_companion/features/tasks/domain/entities/task.dart';

abstract class TaskRepository {
  // Get all tasks
  Future<List<Task>> getAllTasks();

  // Get task by ID
  Future<Task?> getTaskById(String id);

  // Get today's tasks
  Future<List<Task>> getTodayTasks();

  // Get tasks by category
  Future<List<Task>> getTasksByCategory(String categoryId);

  // Get incomplete tasks
  Future<List<Task>> getIncompleteTasks();

  // Create task
  Future<void> createTask(Task task);

  // Update task
  Future<void> updateTask(Task task);

  // Delete task
  Future<void> deleteTask(String id);

  // Toggle task completion
  Future<void> toggleComplete(String id);

  // Add focus minutes to task
  Future<void> addFocusMinutes(String id, int minutes);

  // Stream of all tasks (for reactive UI)
  Stream<List<Task>> watchAllTasks();

  // Stream of today's tasks
  Stream<List<Task>> watchTodayTasks();
}
