import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/error_utils.dart';
import '../models/task_list_model.dart';
import '../providers/task_list_provider.dart';

class AddListScreen extends StatefulWidget {
  const AddListScreen({super.key});

  @override
  State<AddListScreen> createState() => _AddListScreenState();
}

class _AddListScreenState extends State<AddListScreen> {
  final controller = TextEditingController();
  bool _isSaving = false;

  Future<void> saveList() async {
    if (_isSaving) return;

    final name = controller.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập tên danh mục')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<TaskListProvider>().addList(
            TaskListModel(name: name),
          );
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
        title: const Text('Thêm danh mục'),
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
              height: 50,
              child: FilledButton(
                onPressed: _isSaving ? null : saveList,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
