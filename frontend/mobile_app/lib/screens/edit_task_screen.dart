import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
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
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedDateTime;
  late int priority;
  late int selectedListId;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    selectedDateTime = widget.task.reminderTime ?? widget.task.dueDate;
    priority = widget.task.priority;
    selectedListId = widget.task.listId;

    Future.microtask(() async {
      if (!mounted) return;
      await context.read<TaskListProvider>().loadLists();
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
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
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
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên công việc')),
      );
      return;
    }

    final updated = widget.task.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dueDate: selectedDateTime,
      reminderTime: selectedDateTime,
      priority: priority,
      listId: selectedListId,
    );

    await context.read<TaskProvider>().updateTask(updated);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> deleteTask() async {
    await context.read<TaskProvider>().deleteTask(widget.task.id!);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = context.watch<TaskListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tên công việc',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              initialValue: priority,
              decoration: const InputDecoration(
                labelText: 'Mức ưu tiên',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                AppConstants.priorityLabels.length,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text(AppConstants.priorityLabels[index]),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  priority = value ?? 0;
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              initialValue: selectedListId,
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
              ),
              items: listProvider.lists
                  .map(
                    (list) => DropdownMenuItem<int>(
                      value: list.id,
                      child: Text(list.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedListId = value ?? selectedListId;
                });
              },
            ),
            const SizedBox(height: 15),
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Thời gian nhắc'),
                subtitle: Text(selectedDateTime.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: pickDateTime,
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: updateTask,
                child: const Text('Cập nhật'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
