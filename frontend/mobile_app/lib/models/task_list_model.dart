class TaskListModel {
  int? id;
  String name;
  String? description;
  DateTime? createdAt;
  int? userId;

  TaskListModel({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.userId,
  });

  Map<String, dynamic> toApiMap() {
    return {
      'name': name,
      'description': description,
      'userId': userId,
    };
  }

  factory TaskListModel.fromApiJson(Map<String, dynamic> map) {
    return TaskListModel(
      id: map['id'] as int?,
      userId: map['userId'] as int?,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  TaskListModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return TaskListModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
