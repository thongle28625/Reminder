import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  String currentFilter = "Tất cả"; // Lọc theo Priority cũ

  // --- THÊM MỚI ĐỂ ĐIỀU HƯỚNG VÀ LỌC ---
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  String _statusFilter = "Tất cả";
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
  // ------------------------------------

  List<TaskModel> get tasks => _tasks;

  // SỬA LẠI GETTER NÀY ĐỂ LỌC ĐÚNG Ý
  List<TaskModel> get filteredTasks {
    List<TaskModel> list = _tasks;

    // 1. Lọc theo trạng thái từ Dashboard
    if (_statusFilter == "Hoàn thành") {
      list = list.where((t) => t.isCompleted).toList();
    } else if (_statusFilter == "Hôm nay") {
      final now = DateTime.now();
      list = list.where((t) =>
      t.dueDate.year == now.year &&
          t.dueDate.month == now.month &&
          t.dueDate.day == now.day
      ).toList();
    } else if (_statusFilter == "Quá hạn") {
      list = list.where((t) => !t.isCompleted && t.dueDate.isBefore(DateTime.now())).toList();
    }

    // 2. Lọc tiếp theo Priority (Cái dropdown "Tất cả" của bạn)
    if (currentFilter != "Tất cả") {
      list = list.where((task) => task.priority == currentFilter).toList();
    }
    return list;
  }

  int get totalTasks => _tasks.length;

  int get completedTasks =>
      _tasks.where((e) => e.isCompleted).length;

  int get pendingTasks =>
      _tasks.where((e) => !e.isCompleted).length;

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
  List<TaskModel> getTasksByList(
      int listId,
      ) {
    return _tasks.where(
          (task) => task.listId == listId,
    ).toList();
  }

  List<TaskModel> get overdueTasks {
    return _tasks.where((task) {
      return task.dueDate.isBefore(
        DateTime.now(),
      ) &&
          !task.isCompleted;
    }).toList();
  }

  List<TaskModel> get weekTasks {
    final now = DateTime.now();

    final nextWeek =
    now.add(const Duration(days: 7));

    return _tasks.where((task) {
      return task.dueDate.isAfter(now) &&
          task.dueDate.isBefore(nextWeek);
    }).toList();
  }

  void setFilter(String filter) {
    currentFilter = filter;
    notifyListeners();
  }


  Future<void> loadTasks() async {
    final db = await DatabaseHelper.instance.database;

    final maps = await db.rawQuery('''
    SELECT
      tasks.*,
      task_lists.name AS listName
    FROM tasks
    LEFT JOIN task_lists
      ON tasks.listId = task_lists.id
    ORDER BY tasks.dueDate ASC
  ''');

    _tasks = maps
        .map(
          (e) => TaskModel.fromMap(e),
    )
        .toList();

    notifyListeners();
  }

  Future<void> addTask(
      TaskModel task,
      ) async {
    final db = await DatabaseHelper.instance.database;

    final id = await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );

    await NotificationService.instance
        .scheduleNotification(
      id: id,
      title: task.title,
      body: task.description,
      scheduleDate: task.dueDate,
    );

    await loadTasks();
  }

  Future<void> updateTask(
      TaskModel task,
      ) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    await NotificationService.instance
        .updateNotification(
      id: task.id!,
      title: task.title,
      body: task.description,
      scheduleDate: task.dueDate,
    );

    await loadTasks();
  }

  Future<void> deleteTask(
      int id,
      ) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    await NotificationService.instance
        .cancelNotification(id);

    await loadTasks();
  }

  Future<void> toggleComplete(
      TaskModel task,
      ) async {

    task.isCompleted =
    !task.isCompleted;

    await updateTask(task);
  }

  Future<void> deleteAllTasks() async {
    final db = await DatabaseHelper.instance.database;

    await db.delete('tasks');

    await NotificationService.instance
        .cancelAllNotifications();

    await loadTasks();
  }

  Future<void> refresh() async {
    await loadTasks();
  }
}