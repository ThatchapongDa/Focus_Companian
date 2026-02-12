import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focus_companion/core/utils/notification_service.dart';
import 'package:focus_companion/core/utils/wakelock_service.dart';
import 'package:focus_companion/features/focus/domain/entities/focus_session.dart';
import 'package:focus_companion/features/focus/domain/repositories/focus_repository.dart';
import 'package:focus_companion/core/constants/app_constants.dart';

enum TimerState { idle, running, paused, completed }

class TimerService extends ChangeNotifier {
  final FocusRepository _focusRepository;
  final NotificationService _notificationService;
  final WakelockService _wakelockService;

  TimerService(
    this._focusRepository,
    this._notificationService,
    this._wakelockService,
  );

  TimerState _state = TimerState.idle;
  FocusSession? _currentSession;
  Timer? _timer;
  int _remainingSeconds = 0;
  DateTime? _pausedAt;
  int _pausedSecondsRemaining = 0;

  TimerState get state => _state;
  FocusSession? get currentSession => _currentSession;
  int get remainingSeconds => _remainingSeconds;
  double get progress {
    if (_currentSession == null) return 0.0;
    final totalSeconds = _currentSession!.durationMinutes * 60;
    if (totalSeconds == 0) return 0.0;
    return (_remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isRunning => _state == TimerState.running;
  bool get isPaused => _state == TimerState.paused;
  bool get isIdle => _state == TimerState.idle;
  bool get isCompleted => _state == TimerState.completed;

  // Start a new timer session
  Future<void> startTimer({
    required SessionType sessionType,
    required int durationMinutes,
    String? taskId,
  }) async {
    if (_state == TimerState.running) {
      await stopTimer();
    }

    _currentSession = FocusSession(
      taskId: taskId,
      durationMinutes: durationMinutes,
      sessionType: sessionType,
      startTime: DateTime.now(),
    );

    await _focusRepository.createSession(_currentSession!);

    if (sessionType == SessionType.countUp) {
      _remainingSeconds = 0;
    } else {
      _remainingSeconds = durationMinutes * 60;
    }

    _state = TimerState.running;
    _startTicking();
    notifyListeners();

    // Enable wakelock to keep screen on
    await _wakelockService.enable();

    // Show running notification
    await _notificationService.showTimerRunningNotification(
      title: 'Focus Session กำลังทำงาน',
      body: 'เวลา: ${_currentSession!.durationMinutes} นาที',
    );
  }

  // Resume from timestamp (called when app returns from background)
  Future<void> recoverSession(FocusSession session) async {
    _currentSession = session;
    final elapsed = DateTime.now().difference(session.startTime);
    final elapsedSeconds = elapsed.inSeconds;

    if (session.sessionType == SessionType.countUp) {
      _remainingSeconds = elapsedSeconds;
    } else {
      final totalSeconds = session.durationMinutes * 60;
      _remainingSeconds = (totalSeconds - elapsedSeconds).clamp(
        0,
        totalSeconds,
      );

      if (_remainingSeconds <= 0) {
        await _completeSession();
        return;
      }
    }

    _state = TimerState.running;
    _startTicking();
    notifyListeners();

    // Enable wakelock when recovering running session
    await _wakelockService.enable();
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentSession!.sessionType == SessionType.countUp) {
        _remainingSeconds++;
      } else {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _completeSession();
        }
      }
      notifyListeners();
    });
  }

  // Pause timer
  Future<void> pauseTimer() async {
    if (_state != TimerState.running) return;

    _timer?.cancel();
    _pausedAt = DateTime.now();
    _pausedSecondsRemaining = _remainingSeconds;
    _state = TimerState.paused;
    notifyListeners();

    // Disable wakelock when paused
    await _wakelockService.disable();

    await _notificationService.cancelNotification(
      AppConstants.timerRunningNotificationId,
    );
  }

  // Resume timer
  Future<void> resumeTimer() async {
    if (_state != TimerState.paused || _currentSession == null) return;

    // Adjust start time to account for paused duration
    final pausedDuration = DateTime.now().difference(_pausedAt!);
    _currentSession = _currentSession!.copyWith(
      startTime: _currentSession!.startTime.add(pausedDuration),
    );
    await _focusRepository.updateSession(_currentSession!);

    _remainingSeconds = _pausedSecondsRemaining;
    _state = TimerState.running;
    _startTicking();
    notifyListeners();

    // Re-enable wakelock when resuming
    await _wakelockService.enable();

    await _notificationService.showTimerRunningNotification(
      title: 'Focus Session กำลังทำงาน',
      body: 'เวลา: ${_currentSession!.durationMinutes} นาที',
    );
  }

  // Stop timer (cancel session)
  Future<void> stopTimer() async {
    _timer?.cancel();
    _state = TimerState.idle;
    _currentSession = null;
    _remainingSeconds = 0;
    _pausedAt = null;
    _pausedSecondsRemaining = 0;
    notifyListeners();

    // Disable wakelock when stopping
    await _wakelockService.disable();

    await _notificationService.cancelAllNotifications();
  }

  // Complete session
  Future<void> _completeSession() async {
    _timer?.cancel();

    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        isCompleted: true,
      );
      await _focusRepository.updateSession(_currentSession!);
    }

    _state = TimerState.completed;
    notifyListeners();

    // Disable wakelock when completed
    await _wakelockService.disable();

    // Show completion notification
    await _notificationService.showTimerCompleteNotification(
      title: 'Focus Session เสร็จสิ้น! 🎉',
      body: 'คุณโฟกัสได้ ${_currentSession!.actualDurationMinutes} นาที',
    );
  }

  // Add 5 minutes (called from notification action)
  Future<void> addFiveMinutes() async {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      durationMinutes: _currentSession!.durationMinutes + 5,
    );
    await _focusRepository.updateSession(_currentSession!);

    _remainingSeconds += 300; // 5 minutes = 300 seconds
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Ensure wakelock is disabled when service is disposed
    _wakelockService.disable();
    super.dispose();
  }
}
