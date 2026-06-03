class TaskListModel {
  int? id;
  String name;

  TaskListModel({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory TaskListModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return TaskListModel(
      id: map['id'],
      name: map['name'] ?? '',
    );
  }

  TaskListModel copyWith({
    int? id,
    String? name,
  }) {
    return TaskListModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}