import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/error_utils.dart';
import '../models/task_list_model.dart';
import '../providers/task_list_provider.dart';

class EditListScreen extends StatefulWidget {
  final TaskListModel list;

  const EditListScreen({
    super.key,
    required this.list,
  });

  @override
  State<EditListScreen> createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  late TextEditingController controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.list.name);
  }

  Future<void> save() async {
    if (_isSaving) return;

    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập tên danh mục')),
      );
      return;
    }

    final updated = widget.list.copyWith(name: controller.text.trim());
    print('USER ID = ${updated.userId}');
print(updated.toApiMap());

    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<TaskListProvider>().updateList(updated);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa danh mục'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Tên danh mục',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : save,
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
