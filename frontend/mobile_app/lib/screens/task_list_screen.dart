import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_list_model.dart';
import '../providers/task_list_provider.dart';

class TaskListsScreen extends StatefulWidget {
  const TaskListsScreen({super.key});

  @override
  State<TaskListsScreen> createState() =>
      _TaskListsScreenState();
}

class _TaskListsScreenState
    extends State<TaskListsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskListProvider>().loadLists();
    });
  }

  Future<void> _showAddDialog() async {
    final controller =
    TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Thêm danh mục",
          ),
          content: TextField(
            controller: controller,
            decoration:
            const InputDecoration(
              hintText:
              "Tên danh mục",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    context,
                  ),
              child: const Text(
                "Hủy",
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text
                    .trim()
                    .isEmpty) {
                  return;
                }

                final provider =
                    context.read<TaskListProvider>();
                final navigator = Navigator.of(context);

                await provider.addList(
                  TaskListModel(
                    name: controller
                        .text
                        .trim(),
                  ),
                );

                if (!mounted) return;

                navigator.pop();
              },
              child: const Text(
                "Lưu",
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(
      TaskListModel list) async {
    final controller =
    TextEditingController(
      text: list.name,
    );

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Sửa danh mục",
          ),
          content: TextField(
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    context,
                  ),
              child:
              const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider =
                    context.read<TaskListProvider>();
                final navigator = Navigator.of(context);

                await provider.updateList(
                  list.copyWith(
                    name: controller
                        .text
                        .trim(),
                  ),
                );

                if (!mounted) return;

                navigator.pop();
              },
              child:
              const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteList(
      int id) async {
    await context
        .read<TaskListProvider>()
        .deleteList(id);
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<TaskListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quản lý danh mục",
        ),
      ),
      body: ListView.builder(
        itemCount:
        provider.lists.length,
        itemBuilder:
            (context, index) {
          final list =
          provider.lists[index];

          return FutureBuilder<int>(
            future: provider
                .getTaskCount(
              list.id!,
            ),
            builder:
                (context, snapshot) {
              final count =
                  snapshot.data ??
                      0;

              return ListTile(
                leading:
                const Icon(
                  Icons.folder,
                ),
                title:
                Text(list.name),
                subtitle: Text(
                  "$count công việc",
                ),
                trailing: Row(
                  mainAxisSize:
                  MainAxisSize
                      .min,
                  children: [
                    IconButton(
                      icon:
                      const Icon(
                        Icons.edit,
                      ),
                      onPressed: () {
                        _showEditDialog(
                          list,
                        );
                      },
                    ),
                    IconButton(
                      icon:
                      const Icon(
                        Icons.delete,
                      ),
                      onPressed: () {
                        _deleteList(
                          list.id!,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed:
        _showAddDialog,
        child:
        const Icon(Icons.add),
      ),
    );
  }
}