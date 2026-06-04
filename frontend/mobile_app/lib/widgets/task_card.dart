import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../screens/edit_task_screen.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final bool isBusy;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    this.isBusy = false,
  });

  Color _priorityColor() {
    switch (task.priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Opacity(
      opacity: isBusy ? 0.7 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isBusy
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTaskScreen(task: task),
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: isBusy
                      ? const Padding(
                          padding: EdgeInsets.all(2),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) {
                            onToggle();
                          },
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (task.description.isNotEmpty)
                        Text(
                          task.description,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 18, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(dateFormat.format(task.reminderTime ?? task.dueDate)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          PriorityBadge(priority: task.priority),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _priorityColor(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
