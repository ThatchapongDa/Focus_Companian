import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_companion/core/constants/app_constants.dart';
import 'package:focus_companion/core/database/hive_service.dart';
import 'package:focus_companion/features/focus/domain/entities/focus_session.dart';
import 'package:focus_companion/features/focus/domain/repositories/focus_repository.dart';
import 'package:focus_companion/features/tasks/domain/repositories/task_repository.dart';

class FocusRepositoryImpl implements FocusRepository {
  final HiveService _hiveService;
  final TaskRepository _taskRepository;
  Box<FocusSession>? _sessionBox;

  FocusRepositoryImpl(this._hiveService, this._taskRepository);

  Future<Box<FocusSession>> get _box async {
    if (_sessionBox != null && _sessionBox!.isOpen) {
      return _sessionBox!;
    }
    _sessionBox = await _hiveService.openBox<FocusSession>(
      AppConstants.sessionsBoxName,
    );
    return _sessionBox!;
  }

  @override
  Future<void> createSession(FocusSession session) async {
    final box = await _box;
    await box.put(session.id, session);
  }

  @override
  Future<void> updateSession(FocusSession session) async {
    final box = await _box;
    await box.put(session.id, session);

    // If session is completed and linked to a task, update task's focus minutes
    if (session.isCompleted && session.taskId != null) {
      final focusMinutes = session.actualDurationMinutes;
      await _taskRepository.addFocusMinutes(session.taskId!, focusMinutes);
    }
  }

  @override
  Future<FocusSession?> getSessionById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  @override
  Future<List<FocusSession>> getSessionsByTask(String taskId) async {
    final box = await _box;
    return box.values.where((session) => session.taskId == taskId).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<List<FocusSession>> getSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final box = await _box;
    return box.values.where((session) {
      return session.startTime.isAfter(start) &&
          session.startTime.isBefore(end);
    }).toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<List<FocusSession>> getTodaySessions() async {
    final box = await _box;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return box.values.where((session) {
      return session.startTime.isAfter(startOfDay) &&
          session.startTime.isBefore(endOfDay);
    }).toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<List<FocusSession>> getAllSessions() async {
    final box = await _box;
    return box.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<int> getTotalFocusMinutesForTask(String taskId) async {
    final sessions = await getSessionsByTask(taskId);
    return sessions
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, s) => sum + s.actualDurationMinutes);
  }

  @override
  Future<int> getTodayFocusMinutes() async {
    final sessions = await getTodaySessions();
    return sessions
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, s) => sum + s.actualDurationMinutes);
  }

  @override
  Future<int> getFocusMinutesForDateRange(DateTime start, DateTime end) async {
    final sessions = await getSessionsByDateRange(start, end);
    return sessions
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, s) => sum + s.actualDurationMinutes);
  }

  @override
  Future<void> deleteSession(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Stream<List<FocusSession>> watchAllSessions() async* {
    final box = await _box;
    yield box.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    await for (final _ in box.watch()) {
      yield box.values.toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    }
  }

  @override
  Stream<List<FocusSession>> watchTodaySessions() async* {
    final box = await _box;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    List<FocusSession> filterTodaySessions() {
      return box.values.where((session) {
        return session.startTime.isAfter(startOfDay) &&
            session.startTime.isBefore(endOfDay);
      }).toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
    }

    yield filterTodaySessions();

    await for (final _ in box.watch()) {
      yield filterTodaySessions();
    }
  }
}
