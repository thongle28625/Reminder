import '../core/constants/app_constants.dart';

class TaskModel {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  DateTime? reminderTime;
  int priority;
  bool isCompleted;
  int listId;
  String? listName;
  DateTime? createdAt;
  DateTime? updatedAt;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.reminderTime,
    required this.priority,
    this.isCompleted = false,
    required this.listId,
    this.listName,
    this.createdAt,
    this.updatedAt,
  });

  String get priorityLabel => AppConstants.priorityLabel(priority);

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'listId': listId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiMap() {
    return {
      'taskListId': listId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'reminderTime': (reminderTime ?? dueDate).toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromLocalMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      dueDate: DateTime.parse(map['dueDate'].toString()),
      reminderTime: map['reminderTime'] != null
          ? DateTime.tryParse(map['reminderTime'].toString())
          : null,
      priority: _parsePriority(map['priority']),
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
      listId: (map['listId'] ?? map['taskListId'] ?? 1) as int,
      listName: map['listName']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  factory TaskModel.fromApiJson(Map<String, dynamic> map) {
    final taskList = map['taskList'] as Map<String, dynamic>?;

    return TaskModel(
      id: map['id'] as int?,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      dueDate: DateTime.tryParse(map['dueDate']?.toString() ?? '') ?? DateTime.now(),
      reminderTime: map['reminderTime'] != null
          ? DateTime.tryParse(map['reminderTime'].toString())
          : null,
      priority: _parsePriority(map['priority']),
      isCompleted: map['isCompleted'] == true || map['isCompleted'] == 1,
      listId: (map['taskListId'] ?? map['listId'] ?? 1) as int,
      listName: taskList?['name']?.toString() ?? map['listName']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  static int _parsePriority(dynamic raw) {
    if (raw is int) {
      return raw.clamp(0, 2);
    }

    if (raw is String) {
      final parsed = int.tryParse(raw);
      if (parsed != null) {
        return parsed.clamp(0, 2);
      }

      return AppConstants.priorityValue(raw);
    }

    return 0;
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderTime,
    int? priority,
    bool? isCompleted,
    int? listId,
    String? listName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      listId: listId ?? this.listId,
      listName: listName ?? this.listName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
