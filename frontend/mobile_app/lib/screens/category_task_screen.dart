import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/error_utils.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class CategoryTaskScreen extends StatefulWidget {
  final int listId;
  final String title;

  const CategoryTaskScreen({
    super.key,
    required this.listId,
    required this.title,
  });

  @override
  State<CategoryTaskScreen> createState() => _CategoryTaskScreenState();
}

class _CategoryTaskScreenState extends State<CategoryTaskScreen> {
  late Future<void> _loadTasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasksFuture = _loadTasks();
  }

  Future<void> _loadTasks() {
    return context.read<TaskProvider>().loadTasks();
  }

  Future<bool> _deleteTask(BuildContext context, TaskProvider provider, int id) async {
    if (provider.isTaskBusy(id)) return false;

    try {
      await provider.deleteTask(id);
      return true;
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, error, contextLabel: 'Không xóa được công việc.');
      }
      return false;
    }
  }

  Future<void> _toggleTask(BuildContext context, TaskProvider provider, dynamic task) async {
    if (provider.isTaskBusy(task.id)) return;

    try {
      await provider.toggleComplete(task);
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, error, contextLabel: 'Không cập nhật được trạng thái công việc.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks.where((task) => task.listId == widget.listId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} (${tasks.length})'),
      ),
      body: FutureBuilder<void>(
        future: _loadTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          }

          if (tasks.isEmpty) {
            return const Center(
              child: Text('Chưa có công việc'),
            );
          }

          return ListView.builder(
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
          );
        },
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contextualizeError('Không tải được công việc trong danh mục này.', error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadTasksFuture = _loadTasks();
                });
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
