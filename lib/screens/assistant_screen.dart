import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_item.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key, required this.tasks});
  final List<TaskItem> tasks;

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _input = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'مرحبًا! أنا مساعد محلي بسيط. اسألني: ما الوقت الآن؟ أو كم عدد المهام؟'
    }
  ];

  String _answer(String prompt) {
    final q = prompt.toLowerCase();
    if (q.contains('وقت') || q.contains('ساعة') || q.contains('الآن')) {
      return 'الوقت الآن ${DateFormat('HH:mm').format(DateTime.now())}.';
    }
    if (q.contains('عدد') || q.contains('كم') || q.contains('مهام')) {
      return 'لديك ${widget.tasks.length} مهمة محفوظة في القائمة الحالية.';
    }
    final now = DateTime.now();
    final active = widget.tasks.where((t) =>
        !t.isCompleted && !now.isBefore(t.start) && now.isBefore(t.end));
    if (active.isNotEmpty) return 'مهمتك الحالية: ${active.first.title}.';
    return 'أستطيع حاليًا معرفة الوقت وعدد المهام والمهمة الجارية فقط. هذا ليس مساعد ذكاء اصطناعي متصلًا.';
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messages.add({'role': 'assistant', 'text': _answer(text)});
      _input.clear();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('المساعد الذكي')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerLeft : Alignment.centerRight,
                    child: Card(
                      color: isUser
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(message['text']!),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'اكتب سؤالك هنا...',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
