import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/task_list_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() =>
      _EditTaskScreenState();
}

class _EditTaskScreenState
    extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late DateTime selectedDateTime;
  late String priority;
  late int selectedListId;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.task.title,
    );

    descriptionController =
        TextEditingController(
          text: widget.task.description,
        );

    selectedDateTime =
        widget.task.dueDate;

    priority = widget.task.priority;

    selectedListId =
        widget.task.listId;

    Future.microtask(() {
      if (!mounted) return;

      context
          .read<TaskProvider>()
          .loadTasks();
    });
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime:
      TimeOfDay.fromDateTime(
        selectedDateTime,
      ),
    );

    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> updateTask() async {
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

    widget.task.title =
        titleController.text.trim();

    widget.task.description =
        descriptionController.text
            .trim();

    widget.task.dueDate =
        selectedDateTime;

    widget.task.priority =
        priority;

    widget.task.listId =
        selectedListId;

    await context
        .read<TaskProvider>()
        .updateTask(widget.task);

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> deleteTask() async {
    await context
        .read<TaskProvider>()
        .deleteTask(widget.task.id!);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final listProvider =
    context.watch<TaskListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sửa công việc",
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
            ),
            onPressed: deleteTask,
          ),
        ],
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
                  child: Text('Thấp'),
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

            DropdownButtonFormField<
                int>(
              initialValue:
              selectedListId,
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
                  value!;
                });
              },
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.schedule,
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
                updateTask,
                child: const Text(
                  "Cập nhật",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}