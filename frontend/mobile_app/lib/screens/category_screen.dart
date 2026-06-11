import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/error_utils.dart';
import '../providers/task_list_provider.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import 'add_list_screen.dart';
import 'category_task_screen.dart';
import 'edit_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() {
    final listProvider = context.read<TaskListProvider>();
    final taskProvider = context.read<TaskProvider>();

    return Future.wait([
      listProvider.loadLists(),
      taskProvider.loadTasks(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = context.watch<TaskListProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý danh mục')),
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          }

          if (listProvider.lists.isEmpty) {
            return const Center(child: Text('Chưa có danh mục'));
          }

          return ListView.builder(
            itemCount: listProvider.lists.length,
            itemBuilder: (context, index) {
              final list = listProvider.lists[index];
              final count = taskProvider.tasks.where((task) => task.listId == list.id).length;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(list.name),
                  subtitle: Text('$count công việc'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryTaskScreen(listId: list.id!, title: list.name),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditListScreen(list: list),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Xóa danh mục'),
                              content: Text("Bạn có chắc muốn xóa '${list.name}' ?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('Hủy'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              final tasksInList = taskProvider.tasks
                                  .where((task) => task.listId == list.id)
                                  .toList();

                              for (final task in tasksInList) {
                                if (task.id != null) {
                                  await NotificationService.instance.cancelNotification(task.id!);
                                }
                              }

                              await listProvider.deleteList(list.id!);
                              await taskProvider.loadTasks();
                            } catch (error) {
                              if (!context.mounted) return;
                              showErrorSnackBar(context, error, contextLabel: 'Không xóa được danh mục.');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddListScreen()),
          );
        },
        child: const Icon(Icons.add),
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
              contextualizeError('Không tải được danh mục.', error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadDataFuture = _loadData();
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
