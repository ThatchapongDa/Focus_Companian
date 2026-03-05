import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/core/constants/app_constants.dart';
import 'package:focus_companion/features/focus/data/providers/focus_providers.dart';
import 'package:focus_companion/features/focus/presentation/widgets/timer_display.dart';
import 'package:focus_companion/features/focus/presentation/widgets/number_picker.dart';
import 'package:focus_companion/features/tasks/data/providers/task_providers.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Session'),
        actions: [
          if (timerService.isRunning || timerService.isPaused)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('หยุด Session?'),
                    content: const Text(
                      'คุณแน่ใจหรือไม่ที่จะหยุด session นี้?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('หยุด'),
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
            // Timer Display
            TimerDisplay(
              remainingSeconds: timerService.remainingSeconds,
              progress: timerService.progress,
              isRunning: timerService.isRunning,
              sessionType: _selectedSessionType,
            ),
            const SizedBox(height: 48),

            // Control Buttons
            if (timerService.isIdle || timerService.isCompleted) ...[
              // Session Type Selector
              Text(
                'ประเภท Session',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SegmentedButton<SessionType>(
                segments: const [
                  ButtonSegment(
                    value: SessionType.pomodoro,
                    label: Text('Pomodoro'),
                    icon: Icon(Icons.timer),
                  ),
                  ButtonSegment(
                    value: SessionType.custom,
                    label: Text('กำหนดเอง'),
                    icon: Icon(Icons.edit),
                  ),
                  ButtonSegment(
                    value: SessionType.countUp,
                    label: Text('นับขึ้น'),
                    icon: Icon(Icons.trending_up),
                  ),
                ],
                selected: {_selectedSessionType},
                onSelectionChanged: (Set<SessionType> selected) {
                  setState(() => _selectedSessionType = selected.first);
                },
              ),
              const SizedBox(height: 24),

              // Custom Duration Picker
              if (_selectedSessionType == SessionType.custom) ...[
                Text(
                  'ระยะเวลา',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                NumberPicker(
                  minValue: 1,
                  maxValue: 120,
                  value: _customMinutes,
                  step: 5,
                  suffix: ' นาที',
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
                      Text(
                        'เชื่อมโยงกับงาน (ไม่บังคับ)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedTaskId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'เลือกงาน',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('ไม่เชื่อมโยง'),
                          ),
                          ...incompleteTasks.map((task) {
                            return DropdownMenuItem(
                              value: task.id,
                              child: Text(task.title),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedTaskId = value);
                        },
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // Start Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await timerService.startTimer(
                      sessionType: _selectedSessionType,
                      durationMinutes: _durationMinutes,
                      taskId: _selectedTaskId,
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'เริ่ม Focus',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ] else if (timerService.isRunning) ...[
              // Pause Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await timerService.pauseTimer();
                  },
                  icon: const Icon(Icons.pause, size: 28),
                  label: const Text(
                    'หยุดชั่วคราว',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else if (timerService.isPaused) ...[
              // Resume Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await timerService.resumeTimer();
                  },
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'ดำเนินการต่อ',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],

            // Completion Message
            if (timerService.isCompleted) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Session เสร็จสิ้น! เยี่ยมมาก! 🎉',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
