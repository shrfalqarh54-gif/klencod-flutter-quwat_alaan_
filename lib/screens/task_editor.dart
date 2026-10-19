import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_item.dart';
import '../services/task_store.dart';

class TaskEditor extends StatefulWidget {
  const TaskEditor({super.key});
  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _start = TimeOfDay.now();
  TimeOfDay _end = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

  DateTime _combine(TimeOfDay t) => DateTime(_date.year, _date.month, _date.day, t.hour, t.minute);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool start) async {
    final picked = await showTimePicker(context: context, initialTime: start ? _start : _end);
    if (picked != null) setState(() { if (start) { _start = picked; } else { _end = picked; } });
  }

  @override
  void dispose() { _title.dispose(); _description.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('إضافة مهمة')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'اسم المهمة', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'اكتب اسم المهمة' : null),
          const SizedBox(height: 12),
          TextField(controller: _description, maxLines: 3, decoration: const InputDecoration(labelText: 'الوصف (اختياري)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Card(child: ListTile(leading: const Icon(Icons.calendar_month), title: const Text('التاريخ'),
            subtitle: Text('${_date.day}/${_date.month}/${_date.year}'), onTap: _pickDate)),
          Card(child: ListTile(leading: const Icon(Icons.alarm), title: const Text('وقت البداية'),
            subtitle: Text(_start.format(context)), onTap: () => _pickTime(true))),
          Card(child: ListTile(leading: const Icon(Icons.alarm_on), title: const Text('وقت النهاية'),
            subtitle: Text(_end.format(context)), onTap: () => _pickTime(false))),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('حفظ المهمة'),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              var start = _combine(_start);
              var end = _combine(_end);
              if (!end.isAfter(start)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب أن تكون النهاية بعد البداية في اليوم نفسه.')));
                return;
              }
              final error = await context.read<TaskStore>().addTask(TaskItem(
                title: _title.text.trim(),
                description: _description.text.trim(),
                startAt: start,
                endAt: end,
              ));
              if (!mounted) return;
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ]),
      ),
    ),
  );
}
