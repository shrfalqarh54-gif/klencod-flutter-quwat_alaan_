import 'package:flutter/material.dart';

import '../models/task_item.dart';

class TaskEditor extends StatefulWidget {
  const TaskEditor({super.key});

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime _start = DateTime.now().add(const Duration(minutes: 10));
  DateTime _end = DateTime.now().add(const Duration(minutes: 40));

  Future<void> _chooseDateTime(bool chooseStart) async {
    final initial = chooseStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    final value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (chooseStart) {
        _start = value;
        if (!_end.isAfter(_start)) _end = _start.add(const Duration(minutes: 30));
      } else {
        _end = value;
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (!_end.isAfter(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وقت النهاية يجب أن يكون بعد وقت البداية.')),
      );
      return;
    }
    Navigator.pop(
      context,
      TaskItem(
        title: _title.text.trim(),
        description: _description.text.trim(),
        start: _start,
        end: _end,
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('إضافة مهمة')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'اسم المهمة'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'اكتب اسم المهمة' : null,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'الوصف (اختياري)'),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('بداية المهمة'),
                subtitle: Text(_format(_start)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () => _chooseDateTime(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('نهاية المهمة'),
                subtitle: Text(_format(_end)),
                trailing: const Icon(Icons.schedule),
                onTap: () => _chooseDateTime(false),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('حفظ المهمة'),
              ),
            ],
          ),
        ),
      );

  String _format(DateTime value) =>
      '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
