class TaskListModel {
  int? id;
  String name;
  String? description;
  DateTime? createdAt;

  TaskListModel({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiMap() {
    return {
      'name': name,
      'description': description,
    };
  }

  factory TaskListModel.fromLocalMap(Map<String, dynamic> map) {
    return TaskListModel(
      id: map['id'] as int?,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  factory TaskListModel.fromApiJson(Map<String, dynamic> map) {
    return TaskListModel(
      id: map['id'] as int?,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  TaskListModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return TaskListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
