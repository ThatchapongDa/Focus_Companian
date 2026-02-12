import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/core/utils/notification_service.dart';
import 'package:focus_companion/core/utils/wakelock_service.dart';
import 'package:focus_companion/features/focus/domain/entities/focus_session.dart';
import 'package:focus_companion/features/focus/domain/repositories/focus_repository.dart';
import 'package:focus_companion/features/focus/data/repositories/focus_repository_impl.dart';
import 'package:focus_companion/features/focus/domain/services/timer_service.dart';
import 'package:focus_companion/features/tasks/data/providers/task_providers.dart';

// Focus Repository Provider
final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);
  return FocusRepositoryImpl(hiveService, taskRepository);
});

// Timer Service Provider
final timerServiceProvider = ChangeNotifierProvider<TimerService>((ref) {
  final focusRepository = ref.watch(focusRepositoryProvider);
  final notificationService = NotificationService();
  return TimerService(
    focusRepository,
    notificationService,
    WakelockServiceImpl(),
  );
});

// All Sessions Stream Provider
final allSessionsProvider = StreamProvider<List<FocusSession>>((ref) {
  final repository = ref.watch(focusRepositoryProvider);
  return repository.watchAllSessions();
});

// Today's Sessions Stream Provider
final todaySessionsProvider = StreamProvider<List<FocusSession>>((ref) {
  final repository = ref.watch(focusRepositoryProvider);
  return repository.watchTodaySessions();
});

// Today's Focus Minutes Provider
final todayFocusMinutesProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(focusRepositoryProvider);
  return repository.getTodayFocusMinutes();
});

// Sessions by Task Provider (Family)
final sessionsByTaskProvider =
    FutureProvider.family<List<FocusSession>, String>((ref, taskId) {
      final repository = ref.watch(focusRepositoryProvider);
      return repository.getSessionsByTask(taskId);
    });

// Total Focus Minutes for Task Provider (Family)
final taskFocusMinutesProvider = FutureProvider.family<int, String>((
  ref,
  taskId,
) {
  final repository = ref.watch(focusRepositoryProvider);
  return repository.getTotalFocusMinutesForTask(taskId);
});
