import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_list_screen.dart';
import '../models/task_list_model.dart';
import '../providers/task_list_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final listProvider = context.watch<TaskListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách nhắc nhở'),
      ),
      body: Column(
        children: [
          _buildFilter(taskProvider),

          Expanded(
            child: taskProvider.filteredTasks.isEmpty
                ? const Center(
              child: Text(
                "Chưa có công việc",
              ),
            )
                : ListView.builder(
              itemCount: listProvider.lists.length,
              itemBuilder: (context, listIndex) {
                final TaskListModel list =
                listProvider.lists[listIndex];

                final tasksInList = taskProvider.filteredTasks
                    .where(
                      (task) => task.listId == list.id,
                )
                    .toList();

                if (tasksInList.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      "${list.name} (${tasksInList.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    children: tasksInList.map((task) {
                      return Dismissible(
                        key: Key(task.id.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding:
                          const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          taskProvider.deleteTask(task.id!);
                        },
                        child: TaskCard(
                          task: task,
                          onTap: () {
                            taskProvider.toggleComplete(task);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
      PopupMenuButton<String>(
        icon: const Icon(
          Icons.add_circle,
          size: 60,
        ),
        onSelected: (value) async {
          if (value == "task") {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const AddTaskScreen(),
              ),
            );

            if (!mounted) return;

            await context
                .read<TaskProvider>()
                .loadTasks();
          }

          if (value == "list") {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const AddListScreen(),
              ),
            );

            if (!mounted) return;

            await context
                .read<TaskListProvider>()
                .loadLists();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: "task",
            child: Text(
              "➕ Thêm lời nhắc",
            ),
          ),
          const PopupMenuItem(
            value: "list",
            child: Text(
              "📁 Thêm danh mục",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: provider.currentFilter,
        items: const [
          DropdownMenuItem(
            value: "Tất cả",
            child: Text("Tất cả"),
          ),
          DropdownMenuItem(
            value: "Thấp",
            child: Text("Thấp"),
          ),
          DropdownMenuItem(
            value: "Trung Bình",
            child: Text("Trung Bình"),
          ),
          DropdownMenuItem(
            value: "Cao",
            child: Text("Cao"),
          ),
        ],
        onChanged: (value) {
          provider.setFilter(value!);
        },
      ),
    );
  }
}