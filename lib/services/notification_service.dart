import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> scheduleTask({
    required int id,
    required String title,
    required DateTime start,
    required DateTime end,
  }) async {
    if (start.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id * 2,
        'بدأت مهمتك الآن',
        title,
        tz.TZDateTime.from(start, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_start_channel',
            'بداية المهام',
            channelDescription: 'تنبيهات بداية المهام',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    }
    if (end.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id * 2 + 1,
        'انتهى وقت المهمة',
        title,
        tz.TZDateTime.from(end, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_end_channel',
            'نهاية المهام',
            channelDescription: 'تنبيهات نهاية المهام',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    }
  }

  Future<void> cancelTask(int id) async {
    await _plugin.cancel(id * 2);
    await _plugin.cancel(id * 2 + 1);
  }
}
