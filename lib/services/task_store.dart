import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/task_item.dart';

class TaskStore {
  TaskStore._();
  static final TaskStore instance = TaskStore._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      p.join(root, 'quwat_alaan.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            start_ms INTEGER NOT NULL,
            end_ms INTEGER NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<TaskItem>> all() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'start_ms ASC');
    return rows.map(TaskItem.fromMap).toList();
  }

  Future<int> insert(TaskItem task) async {
    final db = await database;
    return db.insert('tasks', task.toMap()..remove('id'));
  }

  Future<int> update(TaskItem task) async {
    if (task.id == null) throw ArgumentError('Task id is required');
    final db = await database;
    return db.update('tasks', task.toMap()..remove('id'),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
