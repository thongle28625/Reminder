import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class TaskListView extends StatelessWidget {
  final String title;
  final String filter;

  const TaskListView({
    super.key,
    required this.title,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    List<TaskModel> tasks = provider.tasks;

    if (filter == "Tất cả") {
      tasks = tasks
          .where((t) => !t.isCompleted)
          .toList();
    }
    else if (filter == "Hoàn thành") {
      tasks = tasks
          .where((t) => t.isCompleted)
          .toList();
    }
    else if (filter == "Hôm nay") {
      final now = DateTime.now();

      tasks = tasks.where((t) {
        return !t.isCompleted &&
            t.dueDate.year == now.year &&
            t.dueDate.month == now.month &&
            t.dueDate.day == now.day;
      }).toList();
    }
    else if (filter == "Quá hạn") {
      tasks = tasks.where((t) {
        return !t.isCompleted &&
            t.dueDate.isBefore(
              DateTime.now(),
            );
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          "Không có lời nhắc",
        ),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (
            context,
            index,
            ) {
          final task = tasks[index];

          return TaskCard(
            task: task,
            onTap: () async {
              await provider.toggleComplete(task);
            },
          );
        },
      ),
    );
  }
}