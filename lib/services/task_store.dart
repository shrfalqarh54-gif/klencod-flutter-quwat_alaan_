import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/task_item.dart';
import 'notification_service.dart';

class TaskStore extends ChangeNotifier {
  Database? _db;
  List<TaskItem> _tasks = [];
  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  Future<void> initialize() async {
    final path = p.join(await getDatabasesPath(), 'quwat_alaan.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            start_at INTEGER NOT NULL,
            end_at INTEGER NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    await reload();
  }

  Future<void> reload() async {
    final rows = await _db!.query('tasks', orderBy: 'start_at ASC');
    _tasks = rows.map(TaskItem.fromMap).toList();
    notifyListeners();
  }

  Future<String?> addTask(TaskItem task) async {
    if (task.title.trim().isEmpty) return 'اكتب اسم المهمة أولًا.';
    if (!task.endAt.isAfter(task.startAt)) return 'وقت النهاية يجب أن يكون بعد البداية.';
    final conflict = _tasks.any((t) =>
      !t.completed &&
      task.startAt.isBefore(t.endAt) &&
      task.endAt.isAfter(t.startAt));
    if (conflict) return '⚠️ هذا الوقت محجوز. غيّر الموعد قبل الحفظ.';
    final id = await _db!.insert('tasks', task.toMap()..remove('id'));
    final saved = task.copyWith(id: id);
    try {
      await NotificationService.instance.scheduleTask(saved);
    } catch (_) {
      // Keep the task saved even if notification scheduling is restricted.
    }
    await reload();
    return null;
  }

  Future<void> toggleCompleted(TaskItem task) async {
    final updated = task.copyWith(completed: !task.completed);
    await _db!.update('tasks', updated.toMap()..remove('id'),
      where: 'id = ?', whereArgs: [task.id]);
    await reload();
  }

  Future<void> deleteTask(TaskItem task) async {
    await NotificationService.instance.cancelTask(task.id!);
    await _db!.delete('tasks', where: 'id = ?', whereArgs: [task.id]);
    await reload();
  }
}
