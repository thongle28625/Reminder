import 'package:flutter/material.dart';

import '../models/task_list_model.dart';
import '../services/database_helper.dart';

class TaskListProvider extends ChangeNotifier {
  List<TaskListModel> _lists = [];

  List<TaskListModel> get lists => _lists;

  Future<void> loadLists() async {
    final db =
    await DatabaseHelper.instance.database;

    final maps = await db.query(
      'task_lists',
      orderBy: 'name ASC',
    );

    _lists = maps
        .map(
          (e) =>
          TaskListModel.fromMap(e),
    )
        .toList();

    notifyListeners();
  }

  Future<void> addList(
      TaskListModel list,
      ) async {
    final db =
    await DatabaseHelper.instance.database;

    await db.insert(
      'task_lists',
      list.toMap(),
    );

    await loadLists();
  }

  Future<void> updateList(
      TaskListModel list,
      ) async {
    final db =
    await DatabaseHelper.instance.database;

    await db.update(
      'task_lists',
      list.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );

    await loadLists();
  }

  Future<void> deleteList(
      int id,
      ) async {
    final db =
    await DatabaseHelper.instance.database;

    await db.delete(
      'task_lists',
      where: 'id = ?',
      whereArgs: [id],
    );

    await loadLists();
  }

  TaskListModel? getListById(
      int id,
      ) {
    try {
      return _lists.firstWhere(
            (list) => list.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> getTaskCount(
      int listId,
      ) async {
    final db =
    await DatabaseHelper.instance.database;

    final result =
    await db.rawQuery(
      '''
      SELECT COUNT(*) as total
      FROM tasks
      WHERE listId = ?
      ''',
      [listId],
    );

    return result.first['total']
    as int;
  }

  Future<void> refresh() async {
    await loadLists();
  }
}