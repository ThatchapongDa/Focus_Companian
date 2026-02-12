// App Constants
class AppConstants {
  // Pomodoro Durations (in minutes)
  static const int pomodoroDuration = 25;
  static const int shortBreakDuration = 5;
  static const int longBreakDuration = 15;

  // Timer Types
  static const String timerTypePomodoro = 'pomodoro';
  static const String timerTypeCustom = 'custom';
  static const String timerTypeCountUp = 'countUp';

  // Notification IDs
  static const int timerCompleteNotificationId = 1;
  static const int timerRunningNotificationId = 2;

  // Notification Channels
  static const String timerChannelId = 'timer_channel';
  static const String timerChannelName = 'Timer Notifications';
  static const String timerChannelDescription = 'Notifications for focus timer';

  // Hive Box Names
  static const String tasksBoxName = 'tasks';
  static const String sessionsBoxName = 'focus_sessions';
  static const String focusSessionsBoxName = 'focus_sessions';
  static const String musicTracksBoxName = 'music_tracks';
  static const String themePreferenceBoxName = 'theme_preference';

  // Default Theme Values
  static const int defaultPrimaryColor = 0xFF6750A4;
  static const int defaultAccentColor = 0xFF7D5260;
  static const String defaultFontFamily = 'Roboto';
}

// Priority Enum
enum Priority {
  low,
  medium,
  high;

  int get value {
    switch (this) {
      case Priority.low:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.high:
        return 3;
    }
  }

  static Priority fromValue(int value) {
    switch (value) {
      case 1:
        return Priority.low;
      case 2:
        return Priority.medium;
      case 3:
        return Priority.high;
      default:
        return Priority.medium;
    }
  }
}

// Session Type Enum
enum SessionType {
  pomodoro,
  custom,
  countUp;

  int get value {
    switch (this) {
      case SessionType.pomodoro:
        return 0;
      case SessionType.custom:
        return 1;
      case SessionType.countUp:
        return 2;
    }
  }

  static SessionType fromValue(int value) {
    switch (value) {
      case 0:
        return SessionType.pomodoro;
      case 1:
        return SessionType.custom;
      case 2:
        return SessionType.countUp;
      default:
        return SessionType.pomodoro;
    }
  }

  String get displayName {
    switch (this) {
      case SessionType.pomodoro:
        return 'Pomodoro';
      case SessionType.custom:
        return 'Custom Timer';
      case SessionType.countUp:
        return 'Count Up';
    }
  }
}

// Music Source Type Enum
enum SourceType {
  youtube,
  local,
  stream;

  String get displayName {
    switch (this) {
      case SourceType.youtube:
        return 'YouTube';
      case SourceType.local:
        return 'Local File';
      case SourceType.stream:
        return 'Stream URL';
    }
  }
}

// App Theme Mode Enum
enum AppThemeMode {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}

// Corner Style Enum
enum CornerStyle {
  soft,
  sharp,
  rounded;

  String get displayName {
    switch (this) {
      case CornerStyle.soft:
        return 'Soft';
      case CornerStyle.sharp:
        return 'Sharp';
      case CornerStyle.rounded:
        return 'Rounded';
    }
  }

  double get radius {
    switch (this) {
      case CornerStyle.soft:
        return 8.0;
      case CornerStyle.sharp:
        return 0.0;
      case CornerStyle.rounded:
        return 16.0;
    }
  }
}
