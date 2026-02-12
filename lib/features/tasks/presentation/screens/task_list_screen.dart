import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/core/routing/app_router.dart';
import 'package:focus_companion/features/tasks/data/providers/task_providers.dart';
import 'package:focus_companion/features/tasks/presentation/widgets/task_card.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasksAsync = ref.watch(allTasksProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('MISSION LOGS')),
      body: allTasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.terminal,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NO ACTIVE OBJECTIVES',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'WAITING FOR COMMAND INPUT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allTasksProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {
                    AppRouter.navigateTo(
                      context,
                      AppRouter.taskDetail,
                      arguments: task.id,
                    );
                  },
                  onToggleComplete: () async {
                    final repo = ref.read(taskRepositoryProvider);
                    await repo.toggleComplete(task.id);
                  },
                  onDelete: () async {
                    final repo = ref.read(taskRepositoryProvider);
                    await repo.deleteTask(task.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OBJECTIVE DELETED'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('SYSTEM ERROR: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRouter.navigateTo(context, AppRouter.taskDetail);
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
