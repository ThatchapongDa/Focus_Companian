import 'package:focus_companion/features/focus/domain/entities/focus_session.dart';

abstract class FocusRepository {
  // Create session
  Future<void> createSession(FocusSession session);

  // Update session
  Future<void> updateSession(FocusSession session);

  // Get session by ID
  Future<FocusSession?> getSessionById(String id);

  // Get sessions by task
  Future<List<FocusSession>> getSessionsByTask(String taskId);

  // Get sessions by date range
  Future<List<FocusSession>> getSessionsByDateRange(
    DateTime start,
    DateTime end,
  );

  // Get today's sessions
  Future<List<FocusSession>> getTodaySessions();

  // Get all sessions
  Future<List<FocusSession>> getAllSessions();

  // Get total focus minutes for a task
  Future<int> getTotalFocusMinutesForTask(String taskId);

  // Get total focus minutes for today
  Future<int> getTodayFocusMinutes();

  // Get total focus minutes for date range
  Future<int> getFocusMinutesForDateRange(DateTime start, DateTime end);

  // Delete session
  Future<void> deleteSession(String id);

  // Stream of all sessions
  Stream<List<FocusSession>> watchAllSessions();

  // Stream of today's sessions
  Stream<List<FocusSession>> watchTodaySessions();
}
