import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/error_utils.dart';
import '../models/task_list_model.dart';
import '../providers/task_list_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_list_screen.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() {
    final taskProvider = context.read<TaskProvider>();
    final listProvider = context.read<TaskListProvider>();

    return Future.wait([
      taskProvider.loadTasks(),
      listProvider.loadLists(),
    ]);
  }

  Future<bool> _deleteTask(BuildContext context, TaskProvider provider, int id) async {
    if (provider.isTaskBusy(id)) return false;

    try {
      await provider.deleteTask(id);
      return true;
    } catch (error) {
      if (!context.mounted) return false;
      showErrorSnackBar(context, error, contextLabel: 'Không xóa được công việc.');
      return false;
    }
  }

  Future<void> _toggleTask(BuildContext context, TaskProvider provider, dynamic task) async {
    if (provider.isTaskBusy(task.id)) return;

    try {
      await provider.toggleComplete(task);
    } catch (error) {
      if (!context.mounted) return;
      showErrorSnackBar(context, error, contextLabel: 'Không cập nhật được trạng thái công việc.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final listProvider = context.watch<TaskListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách nhắc nhở'),
      ),
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          }

          return Column(
            children: [
              _buildFilter(taskProvider),
              Expanded(
                child: taskProvider.filteredTasks.isEmpty
                    ? const Center(
                        child: Text('Chưa có công việc'),
                      )
                    : ListView.builder(
                        itemCount: listProvider.lists.length,
                        itemBuilder: (context, listIndex) {
                          final TaskListModel list = listProvider.lists[listIndex];

                          final tasksInList = taskProvider.filteredTasks
                              .where((task) => task.listId == list.id)
                              .toList();

                          if (tasksInList.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              title: Text(
                                '${list.name} (${tasksInList.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              children: tasksInList.map((task) {
                                final isBusy = taskProvider.isTaskBusy(task.id);

                                return Dismissible(
                                  key: Key(task.id.toString()),
                                  direction: isBusy
                                      ? DismissDirection.none
                                      : DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  confirmDismiss: (_) =>
                                      _deleteTask(context, taskProvider, task.id!),
                                  child: TaskCard(
                                    task: task,
                                    isBusy: isBusy,
                                    onToggle: () => _toggleTask(context, taskProvider, task),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: PopupMenuButton<String>(
        icon: const Icon(
          Icons.add_circle,
          size: 60,
        ),
        onSelected: (value) async {
          final navigator = Navigator.of(context);
          final taskProvider = context.read<TaskProvider>();
          final taskListProvider = context.read<TaskListProvider>();

          if (value == 'task') {
            await navigator.push(
              MaterialPageRoute(
                builder: (_) => const AddTaskScreen(),
              ),
            );

            if (!mounted) return;
            try {
              await taskProvider.loadTasks();
            } catch (error) {
              if (!context.mounted) return;
              showErrorSnackBar(context, error, contextLabel: 'Không tải lại được danh sách công việc.');
            }
          }

          if (value == 'list') {
            await navigator.push(
              MaterialPageRoute(
                builder: (_) => const AddListScreen(),
              ),
            );

            if (!mounted) return;
            try {
              await taskListProvider.loadLists();
            } catch (error) {
              if (!context.mounted) return;
              showErrorSnackBar(context, error, contextLabel: 'Không tải lại được danh mục.');
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'task',
            child: Text('➕ Thêm lời nhắc'),
          ),
          const PopupMenuItem(
            value: 'list',
            child: Text('📁 Thêm danh mục'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: DropdownButton<String>(
        isExpanded: true,
        value: provider.currentFilter,
        items: const [
          DropdownMenuItem(
            value: 'Tất cả',
            child: Text('Tất cả'),
          ),
          DropdownMenuItem(
            value: 'Thấp',
            child: Text('Thấp'),
          ),
          DropdownMenuItem(
            value: 'Trung Bình',
            child: Text('Trung Bình'),
          ),
          DropdownMenuItem(
            value: 'Cao',
            child: Text('Cao'),
          ),
        ],
        onChanged: (value) {
          provider.setFilter(value!);
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
              contextualizeError('Không tải được danh sách nhắc nhở.', error),
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
