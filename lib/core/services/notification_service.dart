import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'tts_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  late TtsService ttsService;

  void registerTtsService(TtsService service) {
    ttsService = service;
  }

  Future<void> initialize() async {
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) async {
        print('NOTIFICATION TAPPED: ${response.payload}');
        if (Platform.isAndroid) {
          await _handleAndroidTTS(response.payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
      _androidBackgroundNotificationHandler,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final status = await Permission.notification.status;
      if (status.isDenied) {
        await androidPlugin?.requestNotificationsPermission();
      }
      await androidPlugin?.requestExactAlarmsPermission();

      final canExact =
          await androidPlugin?.canScheduleExactNotifications() ?? false;
      if (!canExact) {
        print('⚠️ WARNING: Exact alarms disabled. Reminders may be delayed.');
      }

      // DELETE existing channels to force recreation with proper sound settings
      try {
        await androidPlugin
            ?.deleteNotificationChannel('medicine_reminder_channel');
        print('✓ Deleted old medicine_reminder_channel');
      } catch (e) {
        print('Channel deletion info: $e');
      }

      try {
        await androidPlugin
            ?.deleteNotificationChannel('appointment_reminder_channel');
        print('✓ Deleted old appointment_reminder_channel');
      } catch (e) {
        print('Channel deletion info: $e');
      }

      try {
        await androidPlugin
            ?.deleteNotificationChannel('daily_summary_channel');
        print('✓ Deleted old daily_summary_channel');
      } catch (e) {
        print('Channel deletion info: $e');
      }

      // MEDICINE CHANNEL – with proper sound configuration
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'medicine_reminder_channel',
          'Medicine Reminders',
          description: 'Notifications for taking medicines on time',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('tts_sound'),
          enableVibration: true,
          //lightColor: Color(0xFF7A2E2A),
        ),
      );
      print('✓ Created medicine_reminder_channel with sound');

      // APPOINTMENT CHANNEL
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'appointment_reminder_channel',
          'Appointment Reminders',
          description: 'Reminders for doctor appointments',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
         // lightColor: Color(0xFF1565C0),
        ),
      );
      print('✓ Created appointment_reminder_channel');

      // DAILY SUMMARY CHANNEL
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_summary_channel',
          'Daily Summary',
          description: 'Daily health summary notifications',
          importance: Importance.high,
          playSound: true,
          //lightColor: Color(0xFFB5743B),
        ),
      );
      print('✓ Created daily_summary_channel');
    }

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    print('✅ NotificationService initialized successfully');
  }

  // ============================================================================
  // REPEAT TTS 3 TIMES WITH 5 SECOND INTERVAL - USES TtsService.speakRepeatedly
  // ============================================================================
  Future<void> _speakRepeatedly(String message, int times, int intervalSeconds) async {
    await ttsService.speakRepeatedly(message, times: times, intervalSeconds: intervalSeconds);
  }

  @pragma('vm:entry-point')
  static void _androidBackgroundNotificationHandler(
      NotificationResponse response) async {
    if (!Platform.isAndroid) return;

    print('🔔 Background notification handler triggered: ${response.payload}');

    final tts = TtsService();
    try {
      await tts.initialize();

      if (response.payload?.startsWith('medicine_') == true) {
        // Repeat 3 times with 5 second interval
        await _speakRepeatedlyStatic("Time to take medicine", 3, 5, tts);
      } else if (response.payload?.startsWith('appointment_') == true) {
        await _speakRepeatedlyStatic(
            "You have an upcoming appointment", 3, 5, tts);
      } else if (response.payload == 'instant_test') {
        await _speakRepeatedlyStatic(
            "Test notification triggered", 3, 5, tts);
      }
    } catch (e) {
      print("❌ Background TTS failed: $e");
    } finally {
      await tts.stop();
    }
  }

  // Static version for background handler - WAITS for each speak to complete
  static Future<void> _speakRepeatedlyStatic(
      String message,
      int times,
      int intervalSeconds,
      TtsService tts,
      ) async {
    for (int i = 0; i < times; i++) {
      print('🔊 Speaking (${i + 1}/$times): $message');

      // WAIT for this speech to complete before moving to next
      await tts.speak(message);

      // If not the last iteration, wait for interval
      if (i < times - 1) {
        print('⏱️ Waiting ${intervalSeconds}s before next repetition...');
        await Future.delayed(Duration(seconds: intervalSeconds));
      }
    }
    print('✅ Completed speaking $times times');
  }

  Future<void> _handleAndroidTTS(String? payload) async {
    if (!Platform.isAndroid || payload == null) return;

    print('📢 Foreground TTS handler triggered: $payload');

    try {
      if (payload.startsWith('medicine_')) {
        // Repeat 3 times with 5 second interval
        await _speakRepeatedly("Time to take medicine", 3, 5);
      } else if (payload.startsWith('appointment_')) {
        await _speakRepeatedly("You have an upcoming appointment", 3, 5);
      } else if (payload == 'instant_test') {
        await _speakRepeatedly("Test notification triggered", 3, 5);
      }
    } catch (e) {
      print("❌ Foreground TTS failed: $e");
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    print('📤 Showing instant notification: $title');

    const androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Medicine Reminders',
      channelDescription: 'Instant medicine reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      sound: RawResourceAndroidNotificationSound('tts_sound'),
      ticker: 'Medicine Reminder',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'Default',
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.show(
      999999,
      title,
      body,
      details,
      payload: 'instant_test',
    );

    print('✅ Instant notification sent');
  }

  Future<void> scheduleMedicineReminder({
    required String medicineId,
    required String medicineName,
    required String dosage,
    required List<String> timesOfDay,
    required DateTime startDate,
  }) async {
    final now = DateTime.now();

    if (now.isBefore(startDate)) {
      print('⏭️ Medicine $medicineName starts in future. Skipping.');
      return;
    }

    final canExact = await checkExactAlarmsPermission();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    const androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Medicine Reminders',
      channelDescription: 'Daily medicine reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      sound: RawResourceAndroidNotificationSound('tts_sound'),
      visibility: NotificationVisibility.public,
      ticker: 'Take your medicine!',
      category: AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'Default',
    );

    const notifDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    for (String timeStr in timesOfDay) {
      final parts = timeStr.split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      var target = DateTime(now.year, now.month, now.day, hour, minute);
      if (target.isBefore(now)) target = target.add(const Duration(days: 1));

      final scheduledTime = tz.TZDateTime.from(target, tz.local);
      final notificationId = (medicineId.hashCode + timeStr.hashCode).abs();

      final pending = await _notificationsPlugin.pendingNotificationRequests();
      if (pending.any((n) => n.id == notificationId)) {
        print("ℹ️ Already scheduled: $medicineName @ $timeStr (ID: $notificationId)");
        continue;
      }

      try {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          'Time for your medicine!',
          '$medicineName - $dosage',
          scheduledTime,
          notifDetails,
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'medicine_$medicineId',
        );

        print(
            '✅ Scheduled: $medicineName @ $timeStr (ID: $notificationId) for ${scheduledTime.toString()}');
      } catch (e) {
        print('❌ Error scheduling medicine reminder: $e');
      }
    }
  }

  Future<void> scheduleAppointmentReminder({
    required int id,
    required String doctorName,
    required String hospital,
    required DateTime appointmentTime,
  }) async {
    final reminderTime = appointmentTime.subtract(const Duration(hours: 1));
    final tzTime = _toFutureTzDateTime(reminderTime);

    final canExact = await checkExactAlarmsPermission();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    const androidDetails = AndroidNotificationDetails(
      'appointment_reminder_channel',
      'Appointment Reminders',
      channelDescription: 'Doctor appointment reminders',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      ticker: 'Upcoming Appointment',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        'Upcoming Appointment',
        'Dr. $doctorName at $hospital in 1 hour',
        tzTime,
        details,
        androidScheduleMode: scheduleMode,
        payload: 'appointment_$id',
      );

      print('✅ Appointment reminder scheduled for Dr. $doctorName');
    } catch (e) {
      print('❌ Error scheduling appointment: $e');
    }
  }

  Future<void> scheduleDailySummary({
    required int hour,
    required int minute,
  }) async {
    final canExact = await checkExactAlarmsPermission();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    const androidDetails = AndroidNotificationDetails(
      'daily_summary_channel',
      'Daily Summary',
      channelDescription: 'Daily health summary',
      importance: Importance.high,
      priority: Priority.defaultPriority,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notificationsPlugin.zonedSchedule(
        999,
        'Daily Health Summary',
        'Check your pending medicines and appointments',
        _nextInstanceOfTime(hour, minute),
        details,
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Daily summary scheduled for $hour:$minute');
    } catch (e) {
      print('❌ Error scheduling daily summary: $e');
    }
  }

  tz.TZDateTime _toFutureTzDateTime(DateTime dateTime) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime.from(dateTime, tz.local);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print('✅ Notification $id cancelled');
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print('✅ All notifications cancelled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      await _notificationsPlugin.pendingNotificationRequests();

  Future<void> debugScheduleIn10Seconds() async {
    print('📋 Scheduling debug notification in 10 seconds...');

    final canExact = await checkExactAlarmsPermission();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final time = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    const androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Medicine Reminders',
      channelDescription: 'Test notification',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('tts_sound'),
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      ticker: 'DEBUG TEST',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notificationsPlugin.zonedSchedule(
        888888,
        'DEBUG TEST',
        'This notification should appear with SOUND in 10 seconds',
        time,
        details,
        androidScheduleMode: scheduleMode,
        payload: 'instant_test',
      );

      print('✅ Debug notification scheduled for ${time.toString()}');
    } catch (e) {
      print('❌ Error scheduling debug notification: $e');
    }
  }

  Future<bool> checkExactAlarmsPermission() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestExactAlarmsPermission();
    final canExact = await androidPlugin?.canScheduleExactNotifications() ?? false;

    if (!canExact) {
      print(
          '⚠️ Exact alarms permission denied. Reminders may be delayed by Android.');
    } else {
      print('✅ Exact alarms permission granted');
    }

    return canExact;
  }
}