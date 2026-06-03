import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../core/constants/app_constants.dart';
import '../models/task_list_model.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();

    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), AppConstants.databaseName);

    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE task_lists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        reminderTime TEXT,
        priority INTEGER NOT NULL DEFAULT 0,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        listId INTEGER NOT NULL,
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY(listId)
        REFERENCES task_lists(id)
        ON DELETE CASCADE
      )
    ''');

    await _insertDefaultLists(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS task_lists(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');

      await _insertDefaultLists(db);
    }

    if (oldVersion < 3) {
      await _addColumnIfMissing(db, 'task_lists', 'description', 'TEXT');
      await _addColumnIfMissing(db, 'task_lists', 'createdAt', 'TEXT');

      await db.execute('DROP TABLE IF EXISTS tasks_new');
      await db.execute('''
        CREATE TABLE tasks_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          dueDate TEXT NOT NULL,
          reminderTime TEXT,
          priority INTEGER NOT NULL DEFAULT 0,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          listId INTEGER NOT NULL,
          createdAt TEXT,
          updatedAt TEXT,
          FOREIGN KEY(listId)
          REFERENCES task_lists(id)
          ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        INSERT INTO tasks_new(id, title, description, dueDate, reminderTime, priority, isCompleted, listId, createdAt, updatedAt)
        SELECT 
          id,
          title,
          description,
          dueDate,
          dueDate,
          CASE
            WHEN priority = 'Cao' THEN 2
            WHEN priority = 'Trung Bình' THEN 1
            ELSE 0
          END,
          isCompleted,
          listId,
          dueDate,
          dueDate
        FROM tasks
      ''');

      await db.execute('DROP TABLE tasks');
      await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
    }
  }

  Future<void> _insertDefaultLists(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('task_lists', {
      'name': 'Cá nhân',
      'description': 'Công việc cá nhân hàng ngày',
      'createdAt': now,
    });

    await db.insert('task_lists', {
      'name': 'Học tập',
      'description': 'Bài tập, ôn tập, lịch học',
      'createdAt': now,
    });

    await db.insert('task_lists', {
      'name': 'Công việc',
      'description': 'Việc làm thêm hoặc dự án',
      'createdAt': now,
    });

    await db.insert('task_lists', {
      'name': 'Gia đình',
      'description': 'Nhắc việc cho gia đình',
      'createdAt': now,
    });
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String tableName,
    String columnName,
    String columnDefinition,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final exists = columns.any((column) => column['name'] == columnName);

    if (!exists) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition',
      );
    }
  }

  Future<List<TaskListModel>> getLists() async {
    final db = await database;
    final maps = await db.query('task_lists', orderBy: 'name ASC');
    return maps.map(TaskListModel.fromLocalMap).toList();
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT tasks.*, task_lists.name AS listName
      FROM tasks
      LEFT JOIN task_lists ON tasks.listId = task_lists.id
      ORDER BY tasks.dueDate ASC
    ''');

    return maps.map(TaskModel.fromLocalMap).toList();
  }

  Future<void> replaceLists(List<TaskListModel> lists) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('task_lists');
      for (final list in lists) {
        await txn.insert('task_lists', list.toLocalMap());
      }
    });
  }

  Future<void> replaceTasks(List<TaskModel> tasks) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tasks');
      for (final task in tasks) {
        await txn.insert('tasks', task.toLocalMap());
      }
    });
  }

  Future<void> upsertList(TaskListModel list) async {
    final db = await database;
    await db.insert(
      'task_lists',
      list.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertTask(TaskModel task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeList(int id) async {
    final db = await database;
    await db.delete('task_lists', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllTasks() async {
    final db = await database;
    await db.delete('tasks');
  }

  Future<int> getTaskCount(int listId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as total
      FROM tasks
      WHERE listId = ?
      ''',
      [listId],
    );

    return result.first['total'] as int;
  }

  Future<void> resetDatabase() async {
    final path = join(await getDatabasesPath(), AppConstants.databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
