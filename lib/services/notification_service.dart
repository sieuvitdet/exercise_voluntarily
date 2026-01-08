import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/utils/duration_utils.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'workout_timer';
  static const String _channelName = 'Workout Timer';
  static const String _channelDescription = 'Shows workout timer progress';
  static const int _notificationId = 1;

  // Callbacks for notification actions
  Function()? onBreakToggled;
  Function()? onCompleted;

  Future<void> init() async {
    if (!Platform.isAndroid) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          playSound: false,
          enableVibration: false,
        ),
      );

      // Request notification permission for Android 13+
      await androidPlugin.requestNotificationsPermission();
    }
  }

  Future<void> showTimerNotification(
    Duration elapsed, {
    bool isOnBreak = false,
  }) async {
    if (!Platform.isAndroid) return;

    final timeString = DurationUtils.formatMMSS(elapsed);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      category: AndroidNotificationCategory.workout,
      actions: [
        AndroidNotificationAction(
          'break',
          isOnBreak ? 'Resume' : 'Break',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'complete',
          'Complete',
          showsUserInterface: true,
        ),
      ],
    );

    await _notifications.show(
      _notificationId,
      isOnBreak ? 'Workout Paused' : 'Workout Active',
      'Elapsed: $timeString',
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> cancelNotification() async {
    if (!Platform.isAndroid) return;
    await _notifications.cancel(_notificationId);
  }

  void _onNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;

    if (actionId == 'break') {
      onBreakToggled?.call();
    } else if (actionId == 'complete') {
      onCompleted?.call();
    }
  }
}
