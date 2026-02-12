import 'package:hive/hive.dart';
import 'package:focus_companion/core/constants/app_constants.dart';

part 'focus_session.g.dart';

@HiveType(typeId: 1)
class FocusSession extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String? taskId;

  @HiveField(2)
  late DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  late int sessionTypeValue;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  late DateTime createdAt;

  FocusSession({
    String? id,
    this.taskId,
    DateTime? startTime,
    this.endTime,
    this.durationMinutes = 25,
    SessionType sessionType = SessionType.pomodoro,
    this.isCompleted = false,
    DateTime? createdAt,
  }) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    this.startTime = startTime ?? DateTime.now();
    sessionTypeValue = sessionType.value;
    this.createdAt = createdAt ?? DateTime.now();
  }

  SessionType get sessionType => SessionType.fromValue(sessionTypeValue);

  set sessionType(SessionType value) {
    sessionTypeValue = value.value;
  }

  int get actualDurationMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }

  FocusSession copyWith({
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    SessionType? sessionType,
    bool? isCompleted,
  }) {
    return FocusSession(
      id: id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sessionType: sessionType ?? this.sessionType,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
