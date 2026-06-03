import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_list_model.dart';
import '../providers/task_list_provider.dart';

class EditListScreen extends StatefulWidget {
  final TaskListModel list;

  const EditListScreen({
    super.key,
    required this.list,
  });

  @override
  State<EditListScreen> createState() =>
      _EditListScreenState();
}

class _EditListScreenState
    extends State<EditListScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: widget.list.name,
    );
  }

  Future<void> save() async {
    if (controller.text.trim().isEmpty) {
      return;
    }

    final updated = widget.list.copyWith(
      name: controller.text.trim(),
    );

    await context
        .read<TaskListProvider>()
        .updateList(updated);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Sửa danh mục"),
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
              child: FilledButton(
                onPressed: save,
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