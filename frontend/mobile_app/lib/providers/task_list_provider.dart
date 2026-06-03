import 'package:flutter/material.dart';

import '../models/task_list_model.dart';
import '../services/database_helper.dart';
import '../services/task_list_api_service.dart';

class TaskListProvider extends ChangeNotifier {
  TaskListProvider({TaskListApiService? apiService})
      : _apiService = apiService ?? TaskListApiService();

  final TaskListApiService _apiService;
  List<TaskListModel> _lists = [];

  List<TaskListModel> get lists => _lists;

  Future<void> loadLists() async {
    try {
      final remoteLists = await _apiService.fetchLists();
      _lists = remoteLists;
      await DatabaseHelper.instance.replaceLists(remoteLists);
    } catch (_) {
      _lists = await DatabaseHelper.instance.getLists();
    }

    notifyListeners();
  }

  Future<void> addList(TaskListModel list) async {
    try {
      final created = await _apiService.createList(list);
      await DatabaseHelper.instance.upsertList(created);
    } catch (_) {
      await DatabaseHelper.instance.upsertList(
        list.copyWith(createdAt: DateTime.now()),
      );
    }

    await loadLists();
  }

  Future<void> updateList(TaskListModel list) async {
    try {
      final updated = await _apiService.updateList(list);
      await DatabaseHelper.instance.upsertList(updated);
    } catch (_) {
      await DatabaseHelper.instance.upsertList(list);
    }

    await loadLists();
  }

  Future<void> deleteList(int id) async {
    try {
      await _apiService.deleteList(id);
    } catch (_) {
      // Fall back to local removal so the app remains usable offline.
    }

    await DatabaseHelper.instance.removeList(id);
    await loadLists();
  }

  TaskListModel? getListById(int id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> getTaskCount(int listId) async {
    return DatabaseHelper.instance.getTaskCount(listId);
  }

  Future<void> refresh() async {
    await loadLists();
  }
}
