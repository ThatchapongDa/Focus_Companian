import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:focus_companion/core/constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _notifications =
      fln.FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = fln.InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = fln.AndroidNotificationChannel(
      AppConstants.timerChannelId,
      AppConstants.timerChannelName,
      description: AppConstants.timerChannelDescription,
      importance: fln.Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  void _onNotificationTapped(fln.NotificationResponse response) {
    // Handle notification actions
    if (response.actionId == 'stop_session') {
      // TODO: Stop the current session
    } else if (response.actionId == 'add_5_minutes') {
      // TODO: Add 5 minutes to current session
    }
  }

  Future<void> showTimerCompleteNotification({
    required String title,
    required String body,
  }) async {
    final androidDetails = fln.AndroidNotificationDetails(
      AppConstants.timerChannelId,
      AppConstants.timerChannelName,
      channelDescription: AppConstants.timerChannelDescription,
      importance: fln.Importance.high,
      priority: fln.Priority.high,
      actions: <fln.AndroidNotificationAction>[
        fln.AndroidNotificationAction(
          'stop_session',
          'หยุด Session',
          showsUserInterface: true,
        ),
        fln.AndroidNotificationAction(
          'add_5_minutes',
          '+5 นาที',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = fln.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = fln.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      AppConstants.timerCompleteNotificationId,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> showTimerRunningNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = fln.AndroidNotificationDetails(
      AppConstants.timerChannelId,
      AppConstants.timerChannelName,
      channelDescription: AppConstants.timerChannelDescription,
      importance: fln.Importance.low,
      priority: fln.Priority.low,
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = fln.DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const notificationDetails = fln.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      AppConstants.timerRunningNotificationId,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
