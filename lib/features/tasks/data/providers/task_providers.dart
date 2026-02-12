import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/core/database/hive_service.dart';
import 'package:focus_companion/features/tasks/domain/entities/task.dart';
import 'package:focus_companion/features/tasks/domain/repositories/task_repository.dart';
import 'package:focus_companion/features/tasks/data/repositories/task_repository_impl.dart';

// Hive Service Provider
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

// Task Repository Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return TaskRepositoryImpl(hiveService);
});

// All Tasks Stream Provider
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllTasks();
});

// Today's Tasks Stream Provider
final todayTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTodayTasks();
});

// Incomplete Tasks Provider
final incompleteTasksProvider = FutureProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getIncompleteTasks();
});

// Tasks by Category Provider (Family)
final tasksByCategoryProvider = FutureProvider.family<List<Task>, String>((
  ref,
  categoryId,
) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTasksByCategory(categoryId);
});

// Task by ID Provider (Family)
final taskByIdProvider = FutureProvider.family<Task?, String>((ref, id) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(id);
});
