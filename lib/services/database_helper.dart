import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
  DatabaseHelper._internal();

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
    final path = join(
      await getDatabasesPath(),
      'task_manager.db',
    );

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE task_lists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        priority TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        listId INTEGER NOT NULL,

        FOREIGN KEY(listId)
        REFERENCES task_lists(id)
        ON DELETE CASCADE
      )
    ''');

    await _insertDefaultLists(db);
  }

  Future<void> _onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS task_lists(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');

      await _insertDefaultLists(db);
    }
  }

  Future<void> _insertDefaultLists(
      Database db,
      ) async {
    await db.insert(
      'task_lists',
      {'name': 'Cá nhân'},
    );

    await db.insert(
      'task_lists',
      {'name': 'Học tập'},
    );

    await db.insert(
      'task_lists',
      {'name': 'Công việc'},
    );

    await db.insert(
      'task_lists',
      {'name': 'Gia đình'},
    );
  }

  Future<void> resetDatabase() async {
    final path = join(
      await getDatabasesPath(),
      'task_manager.db',
    );

    await deleteDatabase(path);

    _database = null;
  }
}