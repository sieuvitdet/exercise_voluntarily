import 'dart:io';
import 'live_activity_service.dart';
import 'notification_service.dart';

class PlatformTimerService {
  final LiveActivityService _liveActivityService;
  final NotificationService _notificationService;

  PlatformTimerService({
    required LiveActivityService liveActivityService,
    required NotificationService notificationService,
  })  : _liveActivityService = liveActivityService,
        _notificationService = notificationService;

  Future<void> init() async {
    if (Platform.isIOS) {
      await _liveActivityService.init();
    } else if (Platform.isAndroid) {
      await _notificationService.init();
    }
  }

  /// Start platform-specific activity (non-blocking, fire and forget)
  void startActivity(DateTime startTime) {
    if (Platform.isIOS) {
      // Fire and forget - don't block the timer
      _liveActivityService.startActivity(startTime);
    } else if (Platform.isAndroid) {
      _notificationService.showTimerNotification(
        Duration.zero,
        isOnBreak: false,
      );
    }
  }

  /// Update platform-specific activity (non-blocking, fire and forget)
  void updateActivity(Duration elapsed, {bool isOnBreak = false}) {
    if (Platform.isIOS) {
      // Fire and forget - don't block the timer
      _liveActivityService.updateActivity(elapsed, isOnBreak: isOnBreak);
    } else if (Platform.isAndroid) {
      _notificationService.showTimerNotification(
        elapsed,
        isOnBreak: isOnBreak,
      );
    }
  }

  /// End platform-specific activity (non-blocking, fire and forget)
  void endActivity() {
    if (Platform.isIOS) {
      _liveActivityService.endActivity();
    } else if (Platform.isAndroid) {
      _notificationService.cancelNotification();
    }
  }
}
