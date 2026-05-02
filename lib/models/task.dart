import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { todo, inProgress, done }

extension TaskPriorityExt on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.high:
        return const Color(0xFFE53935);
      case TaskPriority.medium:
        return const Color(0xFFFB8C00);
      case TaskPriority.low:
        return const Color(0xFF43A047);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.low:
        return Icons.keyboard_double_arrow_down_rounded;
    }
  }
}

extension TaskStatusExt on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return const Color(0xFF5C6BC0);
      case TaskStatus.inProgress:
        return const Color(0xFFFB8C00);
      case TaskStatus.done:
        return const Color(0xFF43A047);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.timelapse_rounded;
      case TaskStatus.done:
        return Icons.check_circle_rounded;
    }
  }
}

class Task {
  final String? objectId;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    this.objectId,
    required this.title,
    required this.description,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != TaskStatus.done;

  Task copyWith({
    String? objectId,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) {
    return Task(
      objectId: objectId ?? this.objectId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert to Back4App ParseObject
  ParseObject toParseObject() {
    final obj = ParseObject('Task')
      ..set('title', title)
      ..set('description', description)
      ..set('priority', priority.name)
      ..set('status', status.name)
      ..set('dueDate', dueDate);

    if (objectId != null) {
      obj.objectId = objectId;
    }

    return obj;
  }

  /// Build Task from Back4App ParseObject
  factory Task.fromParseObject(ParseObject obj) {
    return Task(
      objectId: obj.objectId,
      title: obj.get<String>('title') ?? '',
      description: obj.get<String>('description') ?? '',
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == obj.get<String>('priority'),
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == obj.get<String>('status'),
        orElse: () => TaskStatus.todo,
      ),
      dueDate: obj.get<DateTime>('dueDate'),
      createdAt: obj.createdAt,
      updatedAt: obj.updatedAt,
    );
  }
}
