import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/task_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/task_api_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskApiService? apiService})
      : _apiService = apiService ?? TaskApiService();

  final TaskApiService _apiService;
  List<TaskModel> _tasks = [];
  String currentFilter = 'Tất cả';

  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  String _statusFilter = 'Tất cả';
  String get statusFilter => _statusFilter;

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    _tabIndex = 1;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  List<TaskModel> get tasks => _tasks;

  List<TaskModel> get filteredTasks {
    List<TaskModel> list = _tasks;

    if (_statusFilter == 'Hoàn thành') {
      list = list.where((t) => t.isCompleted).toList();
    } else if (_statusFilter == 'Hôm nay') {
      final now = DateTime.now();
      list = list.where((t) {
        return t.dueDate.year == now.year &&
            t.dueDate.month == now.month &&
            t.dueDate.day == now.day;
      }).toList();
    } else if (_statusFilter == 'Quá hạn') {
      list = list.where((t) => !t.isCompleted && t.dueDate.isBefore(DateTime.now())).toList();
    }

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

  List<TaskModel> getTasksByList(int listId) {
    return _tasks.where((task) => task.listId == listId).toList();
  }

  List<TaskModel> get overdueTasks {
    return _tasks.where((task) {
      return task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    }).toList();
  }

  List<TaskModel> get weekTasks {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return _tasks.where((task) {
      return task.dueDate.isAfter(now) && task.dueDate.isBefore(nextWeek);
    }).toList();
  }

  void setFilter(String filter) {
    currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    try {
      final remoteTasks = await _apiService.fetchTasks();
      _tasks = remoteTasks;
      await DatabaseHelper.instance.replaceTasks(remoteTasks);
    } catch (_) {
      _tasks = await DatabaseHelper.instance.getTasks();
    }

    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    TaskModel storedTask = task;

    try {
      storedTask = await _apiService.createTask(task);
    } catch (_) {
      storedTask = task.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    await DatabaseHelper.instance.upsertTask(storedTask);

    if (storedTask.id != null) {
      await NotificationService.instance.scheduleNotification(
        id: storedTask.id!,
        title: storedTask.title,
        body: storedTask.description,
        scheduleDate: storedTask.reminderTime ?? storedTask.dueDate,
      );
    }

    await loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    TaskModel storedTask = task;

    try {
      storedTask = await _apiService.updateTask(task);
    } catch (_) {
      storedTask = task.copyWith(updatedAt: DateTime.now());
    }

    await DatabaseHelper.instance.upsertTask(storedTask);

    if (storedTask.id != null) {
      await NotificationService.instance.updateNotification(
        id: storedTask.id!,
        title: storedTask.title,
        body: storedTask.description,
        scheduleDate: storedTask.reminderTime ?? storedTask.dueDate,
      );
    }

    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    try {
      await _apiService.deleteTask(id);
    } catch (_) {
      // Fall back to local delete so the app remains usable offline.
    }

    await DatabaseHelper.instance.removeTask(id);
    await NotificationService.instance.cancelNotification(id);
    await loadTasks();
  }

  Future<void> toggleComplete(TaskModel task) async {
    final toggled = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(toggled);
  }

  Future<void> deleteAllTasks() async {
    for (final task in _tasks) {
      if (task.id != null) {
        try {
          await _apiService.deleteTask(task.id!);
        } catch (_) {
          // Continue deleting local cache even if remote is unavailable.
        }
      }
    }

    await DatabaseHelper.instance.deleteAllTasks();
    await NotificationService.instance.cancelAllNotifications();
    await loadTasks();
  }

  Future<void> refresh() async {
    await loadTasks();
  }

  List<String> get availablePriorityFilters => [
        'Tất cả',
        ...AppConstants.priorityLabels,
      ];
}
