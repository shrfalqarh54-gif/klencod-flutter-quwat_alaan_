import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_item.dart';
import '../services/notification_service.dart';
import '../services/task_store.dart';
import 'task_editor.dart';
import 'assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskItem> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await TaskStore.instance.all();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _addTask() async {
    final result = await Navigator.of(context).push<TaskItem>(
      MaterialPageRoute(builder: (_) => const TaskEditor()),
    );
    if (result == null) return;

    final conflict = _tasks.any((t) =>
        result.start.isBefore(t.end) && result.end.isAfter(t.start));
    if (conflict) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ هذا الوقت محجوز بمهمة أخرى')),
      );
      return;
    }

    final id = await TaskStore.instance.insert(result);
    await NotificationService.instance.scheduleTask(
      id: id,
      title: result.title,
      start: result.start,
      end: result.end,
    );
    await _load();
  }

  Future<void> _toggleCompleted(TaskItem task, bool value) async {
    await TaskStore.instance.update(task.copyWith(isCompleted: value));
    await _load();
  }

  Future<void> _delete(TaskItem task) async {
    if (task.id != null) {
      await NotificationService.instance.cancelTask(task.id!);
      await TaskStore.instance.delete(task.id!);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final current = _tasks.where((t) =>
        !t.isCompleted &&
        !now.isBefore(t.start) &&
        now.isBefore(t.end)).toList();
    final next = _tasks.where((t) => t.start.isAfter(now)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('قوة الآن 💪'),
        actions: [
          IconButton(
            tooltip: 'المساعد',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssistantScreen(tasks: _tasks),
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مهمة'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ماذا أفعل الآن؟',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(DateFormat('EEEE، d MMMM yyyy', 'ar').format(now)),
                          Text('الوقت الحالي: ${DateFormat('HH:mm').format(now)}'),
                          const SizedBox(height: 14),
                          if (current.isNotEmpty)
                            Text('المهمة الحالية: ${current.first.title}',
                                style: const TextStyle(fontSize: 17))
                          else
                            const Text('لا توجد مهمة جارية الآن.'),
                          if (next.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('المهمة القادمة: ${next.first.title}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('جدول المهام',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (_tasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 28),
                      child: Center(child: Text('لم تضف أي مهام بعد. ابدأ بمهمة صغيرة!')),
                    ),
                  ..._tasks.map((task) => Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (v) =>
                                _toggleCompleted(task, v ?? false),
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            '${DateFormat('yyyy/MM/dd HH:mm').format(task.start)}\n'
                            'حتى ${DateFormat('HH:mm').format(task.end)}'
                            '${task.description.isEmpty ? '' : '\n${task.description}'}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: 'حذف المهمة',
                            onPressed: () => _delete(task),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                      )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
