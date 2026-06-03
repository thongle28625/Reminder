import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_list_model.dart';
import '../providers/task_list_provider.dart';

class AddListScreen extends StatefulWidget {
  const AddListScreen({super.key});

  @override
  State<AddListScreen> createState() =>
      _AddListScreenState();
}

class _AddListScreenState
    extends State<AddListScreen> {
  final controller =
  TextEditingController();

  Future<void> saveList() async {
    final name =
    controller.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Nhập tên danh mục",
          ),
        ),
      );
      return;
    }

    await context
        .read<TaskListProvider>()
        .addList(
      TaskListModel(
        name: name,
      ),
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thêm danh mục",
        ),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration:
              const InputDecoration(
                labelText:
                "Tên danh mục",
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: saveList,
                child: const Text(
                  "Lưu",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}