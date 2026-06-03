import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/task_list_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() =>
      _AddTaskScreenState();
}

class _AddTaskScreenState
    extends State<AddTaskScreen> {
  final titleController =
  TextEditingController();

  final descriptionController =
  TextEditingController();

  DateTime selectedDateTime =
  DateTime.now().add(
    const Duration(minutes: 1),
  );

  String priority = 'Thấp';

  int? selectedListId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return;

      context
          .read<TaskListProvider>()
          .loadLists();

      final lists = context
          .read<TaskListProvider>()
          .lists;

      if (lists.isNotEmpty) {
        setState(() {
          selectedListId =
              lists.first.id;
        });
      }
    });
  }

  Future<void> pickDateTime() async {
    final date =
    await showDatePicker(
      context: context,
      initialDate:
      selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    if (!mounted) return;

    final time =
    await showTimePicker(
      context: context,
      initialTime:
      TimeOfDay.fromDateTime(
        selectedDateTime,
      ),
    );

    if (time == null) return;

    setState(() {
      selectedDateTime =
          DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
    });
  }

  Future<void> saveTask() async {
    if (titleController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Vui lòng nhập tên công việc",
          ),
        ),
      );
      return;
    }

    if (selectedListId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Vui lòng chọn danh mục",
          ),
        ),
      );
      return;
    }

    final task = TaskModel(
      title:
      titleController.text.trim(),
      description:
      descriptionController.text
          .trim(),
      dueDate: selectedDateTime,
      priority: priority,
      listId: selectedListId!,
      isCompleted: false,
    );

    await context
        .read<TaskProvider>()
        .addTask(task);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final listProvider =
    context.watch<TaskListProvider>();

    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Thêm công việc"),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller:
              titleController,
              decoration:
              const InputDecoration(
                labelText:
                "Tên công việc",
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
              descriptionController,
              maxLines: 3,
              decoration:
              const InputDecoration(
                labelText: "Mô tả",
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<
                String>(
              initialValue: priority,
              decoration:
              const InputDecoration(
                labelText:
                "Mức ưu tiên",
                border:
                OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Thấp',
                  child: Text(
                      'Thấp'),
                ),
                DropdownMenuItem(
                  value:
                  'Trung Bình',
                  child: Text(
                      'Trung Bình'),
                ),
                DropdownMenuItem(
                  value: 'Cao',
                  child:
                  Text('Cao'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  priority =
                  value!;
                });
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<int>(
              initialValue: selectedListId,
              decoration:
              const InputDecoration(
                labelText:
                "Danh mục",
                border:
                OutlineInputBorder(),
              ),
              items: listProvider
                  .lists
                  .map(
                    (list) =>
                    DropdownMenuItem<
                        int>(
                      value:
                      list.id,
                      child: Text(
                        list.name,
                      ),
                    ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedListId =
                      value;
                });
              },
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons
                      .notifications_active,
                ),
                title: const Text(
                  "Thời gian nhắc",
                ),
                subtitle: Text(
                  selectedDateTime
                      .toString(),
                ),
                trailing:
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                  ),
                  onPressed:
                  pickDateTime,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width:
              double.infinity,
              height: 50,
              child:
              FilledButton(
                onPressed:
                saveTask,
                child: const Text(
                  "Lưu công việc",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}