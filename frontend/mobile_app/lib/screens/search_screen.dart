import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import 'edit_task_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String keyword = '';

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;

    final result = tasks.where((task) {
      final key = keyword.toLowerCase();

      return task.title.toLowerCase().contains(key) ||
          task.description.toLowerCase().contains(key) ||
          task.priorityLabel.toLowerCase().contains(key);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm công việc'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc mô tả...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  keyword = value;
                });
              },
            ),
          ),
          Expanded(
            child: result.isEmpty
                ? const Center(
                    child: Text('Không tìm thấy công việc'),
                  )
                : ListView.builder(
                    itemCount: result.length,
                    itemBuilder: (_, index) {
                      final task = result[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: task.isCompleted ? Colors.green : null,
                          ),
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description),
                              const SizedBox(height: 4),
                              Text(
                                'Ưu tiên: ${task.priorityLabel}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTaskScreen(task: task),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
