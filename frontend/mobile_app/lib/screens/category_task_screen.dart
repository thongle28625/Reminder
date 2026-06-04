import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/error_utils.dart';
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

  Future<bool> _deleteTask(BuildContext context, TaskProvider provider, int id) async {
    if (provider.isTaskBusy(id)) return false;

    try {
      await provider.deleteTask(id);
      return true;
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, error);
      }
      return false;
    }
  }

  Future<void> _toggleTask(BuildContext context, TaskProvider provider, task) async {
    if (provider.isTaskBusy(task.id)) return;

    try {
      await provider.toggleComplete(task);
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    final tasks = provider.tasks.where((task) => task.listId == listId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$title (${tasks.length})'),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text('Chưa có công việc'),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isBusy = provider.isTaskBusy(task.id);

                return Dismissible(
                  key: Key(task.id.toString()),
                  direction: isBusy ? DismissDirection.none : DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _deleteTask(context, provider, task.id!),
                  child: TaskCard(
                    task: task,
                    isBusy: isBusy,
                    onToggle: () => _toggleTask(context, provider, task),
                  ),
                );
              },
            ),
    );
  }
}
