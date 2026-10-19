import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/task_item.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleTask(TaskItem task) async {
    if (task.id == null) return;
    await _schedule(
      id: task.id! * 2,
      title: 'بدأت مهمتك: ${task.title}',
      body: 'حان وقت بدء المهمة الآن.',
      date: task.startAt,
    );
    await _schedule(
      id: task.id! * 2 + 1,
      title: 'انتهت مدة المهمة: ${task.title}',
      body: 'انتهى الوقت المحدد للمهمة.',
      date: task.endAt,
    );
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    if (!date.isAfter(DateTime.now())) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'quwat_tasks',
        'تنبيهات المهام',
        channelDescription: 'تنبيهات بداية ونهاية المهام في قوة الآن',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'task:$id',
    );
  }

  Future<void> cancelTask(int taskId) async {
    await _plugin.cancel(taskId * 2);
    await _plugin.cancel(taskId * 2 + 1);
  }
}
