import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/notification_service.dart';
import '../services/task_api_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskApiService? apiService})
      : _apiService = apiService ?? TaskApiService();

  final TaskApiService _apiService;
  List<TaskModel> _tasks = [];
  final Set<int> _busyTaskIds = <int>{};
  String currentFilter = 'Tất cả';

  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  void setTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  List<TaskModel> get tasks => _tasks;

  bool isTaskBusy(int? id) {
    if (id == null) return false;
    return _busyTaskIds.contains(id);
  }

  List<TaskModel> get filteredTasks {
    var list = _tasks;

    if (currentFilter != 'Tất cả') {
      list = list.where((task) => task.priorityLabel == currentFilter).toList();
    }

    return list;
  }

  int get totalTasks => _tasks.length;

  int get completedTasks => _tasks.where((e) => e.isCompleted).length;

  int get pendingTasks => _tasks.where((e) => !e.isCompleted).length;

  double get progress {
    if (_tasks.isEmpty) return 0;
    return completedTasks / _tasks.length;
  }

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.dueDate.year == now.year &&
          task.dueDate.month == now.month &&
          task.dueDate.day == now.day;
    }).toList();
  }

  int getTaskCountByList(int listId) {
    return _tasks.where((task) => task.listId == listId).length;
  }

  List<TaskModel> get overdueTasks {
    return _tasks.where((task) {
      return task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    }).toList();
  }

  void setFilter(String filter) {
    currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    final remoteTasks = await _apiService.fetchTasks();
    _tasks = _sortTasks(remoteTasks);
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    final storedTask = await _apiService.createTask(task);

    if (storedTask.id != null) {
      await NotificationService.instance.scheduleNotification(
        id: storedTask.id!,
        title: storedTask.title,
        body: storedTask.description,
        scheduleDate: storedTask.reminderTime ?? storedTask.dueDate,
      );
    }

    _upsertTaskInMemory(storedTask);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    await _runWithTaskBusy(task.id, () async {
      final storedTask = await _apiService.updateTask(task);

      if (storedTask.id != null) {
        await NotificationService.instance.updateNotification(
          id: storedTask.id!,
          title: storedTask.title,
          body: storedTask.description,
          scheduleDate: storedTask.reminderTime ?? storedTask.dueDate,
        );
      }

      _upsertTaskInMemory(storedTask);
      notifyListeners();
    });
  }

  Future<void> deleteTask(int id) async {
    await _runWithTaskBusy(id, () async {
      await _apiService.deleteTask(id);
      await NotificationService.instance.cancelNotification(id);
      _removeTaskInMemory(id);
      notifyListeners();
    });
  }

  Future<void> toggleComplete(TaskModel task) async {
    if (isTaskBusy(task.id)) return;

    final toggled = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(toggled);
  }

  List<TaskModel> _sortTasks(List<TaskModel> tasks) {
    final sorted = List<TaskModel>.from(tasks);

    sorted.sort((a, b) {
      final completedCompare = a.isCompleted == b.isCompleted
          ? 0
          : (a.isCompleted ? 1 : -1);
      if (completedCompare != 0) return completedCompare;

      final dueDateCompare = a.dueDate.compareTo(b.dueDate);
      if (dueDateCompare != 0) return dueDateCompare;

      final createdA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final createdB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final createdCompare = createdA.compareTo(createdB);
      if (createdCompare != 0) return createdCompare;

      return (a.id ?? 0).compareTo(b.id ?? 0);
    });

    return sorted;
  }

  Future<void> _runWithTaskBusy(int? id, Future<void> Function() action) async {
    if (id == null) {
      await action();
      return;
    }

    if (_busyTaskIds.contains(id)) return;

    _busyTaskIds.add(id);
    notifyListeners();

    try {
      await action();
    } finally {
      _busyTaskIds.remove(id);
      notifyListeners();
    }
  }

  void _upsertTaskInMemory(TaskModel task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);

    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }

    _tasks = _sortTasks(_tasks);
  }

  void _removeTaskInMemory(int id) {
    _tasks = _tasks.where((task) => task.id != id).toList();
  }
}
