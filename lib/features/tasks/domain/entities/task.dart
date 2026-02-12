import 'package:hive/hive.dart';
import 'package:focus_companion/core/constants/app_constants.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? categoryId;

  @HiveField(4)
  late int priorityValue;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  int totalFocusMinutes;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    this.description,
    this.categoryId,
    Priority priority = Priority.medium,
    this.dueDate,
    this.isCompleted = false,
    this.totalFocusMinutes = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    priorityValue = priority.value;
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  Priority get priority => Priority.fromValue(priorityValue);

  set priority(Priority value) {
    priorityValue = value.value;
  }

  Task copyWith({
    String? title,
    String? description,
    String? categoryId,
    Priority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    int? totalFocusMinutes,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }
}
