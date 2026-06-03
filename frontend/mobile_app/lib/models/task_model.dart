class TaskModel {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  String priority;
  bool isCompleted;
  int listId;

  // THÊM
  String? listName;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    required this.listId,
    this.listName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'listId': listId,
    };
  }

  factory TaskModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return TaskModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: DateTime.parse(
        map['dueDate'],
      ),
      priority: map['priority'] ?? 'Thấp',
      isCompleted: map['isCompleted'] == 1,
      listId: map['listId'] ?? 1,

      // THÊM
      listName: map['listName'],
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    int? listId,
    String? listName,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      listId: listId ?? this.listId,
      listName: listName ?? this.listName,
    );
  }
}