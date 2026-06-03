import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  String keyword = '';

  @override
  Widget build(BuildContext context) {
    final tasks =
        context.watch<TaskProvider>().tasks;

    final result = tasks.where((task) {
      return task.title
          .toLowerCase()
          .contains(keyword.toLowerCase());
    }).toList();

    return Scaffold(
      appBar:
      AppBar(title: const Text('Tìm kiếm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Nhập từ khóa...',
              ),
              onChanged: (value) {
                setState(() {
                  keyword = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: result.length,
              itemBuilder: (_, index) {
                return ListTile(
                  title:
                  Text(result[index].title),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}