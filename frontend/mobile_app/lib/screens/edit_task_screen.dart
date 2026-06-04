import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/error_utils.dart';
import '../models/task_model.dart';
import '../providers/task_list_provider.dart';
import '../providers/task_provider.dart';

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
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isLoadingLists = false;

  bool get _isBusy => _isSaving || _isDeleting;

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

      setState(() {
        _isLoadingLists = true;
      });

      try {
        await context.read<TaskListProvider>().loadLists();
      } catch (error) {
        if (!mounted) return;
        showErrorSnackBar(context, error);
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingLists = false;
          });
        }
      }
    });
  }

  Future<void> pickDateTime() async {
    if (_isBusy) return;

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
    if (_isBusy) return;

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

    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<TaskProvider>().updateTask(updated);
    } catch (error) {
      if (!mounted) return;
      showErrorSnackBar(context, error);
      setState(() {
        _isSaving = false;
      });
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> deleteTask() async {
    if (_isBusy) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await context.read<TaskProvider>().deleteTask(widget.task.id!);
    } catch (error) {
      if (!mounted) return;
      showErrorSnackBar(context, error);
      setState(() {
        _isDeleting = false;
      });
      return;
    }

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
            icon: _isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
            onPressed: _isBusy ? null : deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              enabled: !_isBusy,
              decoration: const InputDecoration(
                labelText: 'Tên công việc',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              enabled: !_isBusy,
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
              onChanged: _isBusy
                  ? null
                  : (value) {
                      setState(() {
                        priority = value ?? 0;
                      });
                    },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              initialValue: selectedListId,
              decoration: InputDecoration(
                labelText: 'Danh mục',
                border: const OutlineInputBorder(),
                suffixIcon: _isLoadingLists
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              items: listProvider.lists
                  .map(
                    (list) => DropdownMenuItem<int>(
                      value: list.id,
                      child: Text(list.name),
                    ),
                  )
                  .toList(),
              onChanged: _isBusy || _isLoadingLists
                  ? null
                  : (value) {
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
                  onPressed: _isBusy ? null : pickDateTime,
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isBusy ? null : updateTask,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cập nhật'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
