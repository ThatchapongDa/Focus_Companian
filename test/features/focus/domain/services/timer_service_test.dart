import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:focus_companion/features/focus/domain/services/timer_service.dart';
import 'package:focus_companion/features/focus/domain/repositories/focus_repository.dart';
import 'package:focus_companion/core/utils/notification_service.dart';
import 'package:focus_companion/core/utils/wakelock_service.dart';
import 'package:focus_companion/features/focus/domain/entities/focus_session.dart';
import 'package:focus_companion/core/constants/app_constants.dart';

class MockFocusRepository extends Mock implements FocusRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class MockWakelockService extends Mock implements WakelockService {}

class FakeFocusSession extends Fake implements FocusSession {}

void main() {
  late TimerService timerService;
  late MockFocusRepository mockFocusRepository;
  late MockNotificationService mockNotificationService;
  late MockWakelockService mockWakelockService;

  setUpAll(() {
    registerFallbackValue(FakeFocusSession());
  });

  setUp(() {
    mockFocusRepository = MockFocusRepository();
    mockNotificationService = MockNotificationService();
    mockWakelockService = MockWakelockService();

    timerService = TimerService(
      mockFocusRepository,
      mockNotificationService,
      mockWakelockService,
    );

    // Default setups
    when(
      () => mockFocusRepository.createSession(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockFocusRepository.updateSession(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockNotificationService.showTimerRunningNotification(
        title: any(named: 'title'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => {});
    when(
      () => mockNotificationService.cancelNotification(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockNotificationService.cancelAllNotifications(),
    ).thenAnswer((_) async => {});
    when(
      () => mockNotificationService.showTimerCompleteNotification(
        title: any(named: 'title'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => {});
    when(() => mockWakelockService.enable()).thenAnswer((_) async => {});
    when(() => mockWakelockService.disable()).thenAnswer((_) async => {});
  });

  group('TimerService', () {
    test('initial state should be idle', () {
      expect(timerService.state, TimerState.idle);
      expect(timerService.remainingSeconds, 0);
    });

    test(
      'startTimer should transition to running state and start ticking',
      () async {
        const minutes = 25;
        await timerService.startTimer(
          sessionType: SessionType.pomodoro,
          durationMinutes: minutes,
        );

        expect(timerService.state, TimerState.running);
        expect(timerService.remainingSeconds, minutes * 60);
        verify(() => mockFocusRepository.createSession(any())).called(1);
        verify(() => mockWakelockService.enable()).called(1);
        verify(
          () => mockNotificationService.showTimerRunningNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        ).called(1);
      },
    );

    test('pauseTimer should transition to paused state', () async {
      await timerService.startTimer(
        sessionType: SessionType.pomodoro,
        durationMinutes: 25,
      );

      await timerService.pauseTimer();

      expect(timerService.state, TimerState.paused);
      verify(() => mockWakelockService.disable()).called(1);
      verify(() => mockNotificationService.cancelNotification(any())).called(1);
    });

    test('resumeTimer should transition back to running state', () async {
      await timerService.startTimer(
        sessionType: SessionType.pomodoro,
        durationMinutes: 25,
      );
      await timerService.pauseTimer();

      await timerService.resumeTimer();

      expect(timerService.state, TimerState.running);
      verify(
        () => mockWakelockService.enable(),
      ).called(2); // Initial start + Resume
      verify(
        () => mockNotificationService.showTimerRunningNotification(
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).called(2); // Initial start + Resume
    });

    test('stopTimer should reset to idle state', () async {
      await timerService.startTimer(
        sessionType: SessionType.pomodoro,
        durationMinutes: 25,
      );

      await timerService.stopTimer();

      expect(timerService.state, TimerState.idle);
      expect(timerService.remainingSeconds, 0);
      expect(timerService.currentSession, isNull);
      verify(() => mockWakelockService.disable()).called(1);
    });
  });
}
