import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/core/routing/app_router.dart';
import 'package:focus_companion/features/tasks/data/providers/task_providers.dart';

import 'package:focus_companion/core/widgets/tactical_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FOCUS COMMAND'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () =>
                AppRouter.navigateTo(context, AppRouter.themeSettings),
            tooltip: 'INTERFACE CONFIG',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () =>
                AppRouter.navigateTo(context, AppRouter.statistics),
            tooltip: 'MISSION METRICS',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'COMMAND CENTER',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                color: theme.colorScheme.primary.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'WELCOME, OPERATOR',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.timer,
                    title: 'INITIATE FOCUS',
                    color: Colors.purple,
                    onTap: () {
                      AppRouter.navigateTo(context, AppRouter.focus);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.task_alt,
                    title: 'MISSION LOGS',
                    color: Colors.blue,
                    onTap: () {
                      AppRouter.navigateTo(context, AppRouter.taskList);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.music_note,
                    title: 'AUDIO',
                    color: Colors.green,
                    onTap: () {
                      AppRouter.navigateTo(context, AppRouter.musicSelection);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bar_chart,
                    title: 'METRICS',
                    color: Colors.orange,
                    onTap: () {
                      AppRouter.navigateTo(context, AppRouter.statistics);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Today's Tasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TODAY\'S OBJECTIVES',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AppRouter.navigateTo(context, AppRouter.taskList);
                  },
                  child: Text(
                    'VIEW ALL',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Today's Tasks List
            todayTasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return TacticalCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'NO ACTIVE MISSIONS',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: tasks.take(3).map((task) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TacticalCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (_) async {
                              final repo = ref.read(taskRepositoryProvider);
                              await repo.toggleComplete(task.id);
                            },
                          ),
                          title: Text(
                            task.title.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: task.description != null
                              ? Text(
                                  task.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                )
                              : null,
                          trailing: task.totalFocusMinutes > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${task.totalFocusMinutes}M',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('MISSION ERROR: $error')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRouter.navigateTo(context, AppRouter.taskDetail);
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(),
        icon: const Icon(Icons.add),
        label: const Text('INITIATE MISSION'),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TacticalCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
