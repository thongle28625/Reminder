import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class CategoryTaskScreen extends StatelessWidget {
  final int listId;
  final String title;

  const CategoryTaskScreen({
    super.key,
    required this.listId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    final tasks = provider.tasks
        .where((task) => task.listId == listId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$title (${tasks.length})",
        ),
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          "Chưa có công việc",
        ),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return Dismissible(
            key: Key(
              task.id.toString(),
            ),
            background: Container(
              color: Colors.red,
              alignment:
              Alignment.centerRight,
              padding:
              const EdgeInsets.only(
                right: 20,
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) {
              provider.deleteTask(
                task.id!,
              );
            },
            child: TaskCard(
              task: task,
              onTap: () {
                provider.toggleComplete(
                  task,
                );
              },
            ),
          );
        },
      ),
    );
  }
}