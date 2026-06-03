import '../../models/task_model.dart';

class TaskUtils {
  static List<TaskModel> today(
      List<TaskModel> tasks) {
    final now = DateTime.now();

    return tasks.where((task) {
      return task.dueDate.year ==
          now.year &&
          task.dueDate.month ==
              now.month &&
          task.dueDate.day ==
              now.day;
    }).toList();
  }

  static List<TaskModel> overdue(
      List<TaskModel> tasks) {
    return tasks.where((task) {
      return task.dueDate
          .isBefore(
          DateTime.now()) &&
          !task.isCompleted;
    }).toList();
  }
}