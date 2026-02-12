import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/core/constants/app_constants.dart';
import 'package:focus_companion/features/focus/data/providers/focus_providers.dart';
import 'package:focus_companion/features/focus/presentation/widgets/number_picker.dart';
import 'package:focus_companion/features/tasks/data/providers/task_providers.dart';
import 'package:focus_companion/features/music/presentation/widgets/music_player_widget.dart';
import 'package:focus_companion/features/music/data/providers/music_providers.dart';
import 'package:focus_companion/features/focus/presentation/widgets/tactical_timer_display.dart';
import 'package:focus_companion/core/widgets/glow_button.dart';
import 'package:focus_companion/core/widgets/tactical_card.dart';

class FocusScreen extends ConsumerStatefulWidget {
  final String? preselectedTaskId;

  const FocusScreen({super.key, this.preselectedTaskId});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  SessionType _selectedSessionType = SessionType.pomodoro;
  int _customMinutes = 25;
  String? _selectedTaskId;

  @override
  void initState() {
    super.initState();
    _selectedTaskId = widget.preselectedTaskId;
  }

  int get _durationMinutes {
    switch (_selectedSessionType) {
      case SessionType.pomodoro:
        return AppConstants.pomodoroDuration;
      case SessionType.custom:
        return _customMinutes;
      case SessionType.countUp:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerService = ref.watch(timerServiceProvider);
    final allTasksAsync = ref.watch(allTasksProvider);
    final theme = Theme.of(context);

    // Listen to timer state changes to stop music when session completes
    ref.listen(timerServiceProvider, (previous, next) {
      if (next.isCompleted && !(previous?.isCompleted ?? false)) {
        ref.read(currentPlayerServiceProvider)?.stop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('MISSION CONTROL'),
        actions: [
          if (timerService.isRunning || timerService.isPaused)
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ABORT MISSION?'),
                    content: const Text(
                      'Are you sure you want to stop the current operation?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'ABORT',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await timerService.stopTimer();
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Tactical Timer Display
            TacticalTimerDisplay(
              remainingDuration: Duration(
                seconds: timerService.remainingSeconds,
              ),
              totalDuration: Duration(
                minutes:
                    timerService.currentSession?.durationMinutes ??
                    _durationMinutes,
              ),
              isRunning: timerService.isRunning,
            ),
            const SizedBox(height: 32),

            // Music Player
            const MusicPlayerWidget(),

            const SizedBox(height: 32),

            // Control Sections
            if (timerService.isIdle || timerService.isCompleted) ...[
              // Session Type Selector
              _buildSectionHeader(theme, 'OPERATION TYPE'),
              const SizedBox(height: 12),
              SegmentedButton<SessionType>(
                segments: const [
                  ButtonSegment(
                    value: SessionType.pomodoro,
                    label: Text('POMODORO'),
                  ),
                  ButtonSegment(
                    value: SessionType.custom,
                    label: Text('CUSTOM'),
                  ),
                  ButtonSegment(
                    value: SessionType.countUp,
                    label: Text('COUNT UP'),
                  ),
                ],
                selected: {_selectedSessionType},
                onSelectionChanged: (Set<SessionType> selected) {
                  setState(() => _selectedSessionType = selected.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: theme.colorScheme.primary,
                  selectedForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Custom Duration Picker
              if (_selectedSessionType == SessionType.custom) ...[
                _buildSectionHeader(theme, 'DURATION SELECTION'),
                const SizedBox(height: 16),
                NumberPicker(
                  minValue: 1,
                  maxValue: 120,
                  value: _customMinutes,
                  step: 5,
                  suffix: ' MINUTES',
                  onChanged: (value) {
                    setState(() => _customMinutes = value);
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Task Selector
              allTasksAsync.when(
                data: (tasks) {
                  final incompleteTasks = tasks
                      .where((t) => !t.isCompleted)
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(theme, 'TARGET OBJECTIVE'),
                      const SizedBox(height: 12),
                      TacticalCard(
                        padding: EdgeInsets.zero,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedTaskId,
                          dropdownColor: theme.colorScheme.surface,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            hintText: 'SELECT MISSION',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('NO TARGET'),
                            ),
                            ...incompleteTasks.map((task) {
                              return DropdownMenuItem(
                                value: task.id,
                                child: Text(task.title.toUpperCase()),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedTaskId = value);
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 40),

              // Start Button
              GlowButton(
                label: 'INITIATE OPERATION',
                icon: Icons.power_settings_new,
                onPressed: () async {
                  await timerService.startTimer(
                    sessionType: _selectedSessionType,
                    durationMinutes: _durationMinutes,
                    taskId: _selectedTaskId,
                  );
                },
              ),
            ] else if (timerService.isRunning) ...[
              // Pause Button
              GlowButton(
                label: 'PAUSE OPERATION',
                icon: Icons.pause,
                color: Colors.orange,
                onPressed: () async {
                  await timerService.pauseTimer();
                },
              ),
            ] else if (timerService.isPaused) ...[
              // Resume Button
              GlowButton(
                label: 'RESUME OPERATION',
                icon: Icons.play_arrow,
                onPressed: () async {
                  await timerService.resumeTimer();
                },
              ),
            ],

            // Completion Message
            if (timerService.isCompleted) ...[
              const SizedBox(height: 32),
              TacticalCard(
                isHighlighted: true,
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MISSION ACCOMPLISHED',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            'REPORT FILED SUCCESSFULLY',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
