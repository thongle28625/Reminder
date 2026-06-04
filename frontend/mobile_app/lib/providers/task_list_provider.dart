import 'package:flutter/material.dart';

import '../models/task_list_model.dart';
import '../services/task_list_api_service.dart';

class TaskListProvider extends ChangeNotifier {
  TaskListProvider({TaskListApiService? apiService})
      : _apiService = apiService ?? TaskListApiService();

  final TaskListApiService _apiService;
  List<TaskListModel> _lists = [];

  List<TaskListModel> get lists => _lists;

  Future<void> loadLists() async {
    _lists = await _apiService.fetchLists();
    notifyListeners();
  }

  Future<void> addList(TaskListModel list) async {
    await _apiService.createList(list);
    await loadLists();
  }

  Future<void> updateList(TaskListModel list) async {
    await _apiService.updateList(list);
    await loadLists();
  }

  Future<void> deleteList(int id) async {
    await _apiService.deleteList(id);
    _lists = _lists.where((list) => list.id != id).toList();
    notifyListeners();
  }
}
