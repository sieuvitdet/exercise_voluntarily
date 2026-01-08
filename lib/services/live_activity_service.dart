import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/url_scheme_data.dart';

class LiveActivityService {
  final LiveActivities _liveActivities = LiveActivities();
  String? _currentActivityId;
  StreamSubscription<UrlSchemeData>? _urlSchemeSubscription;

  // Callback for handling URL scheme actions from Live Activity
  Function()? onBreakToggled;
  Function()? onCompleted;

  Future<void> init() async {
    if (!Platform.isIOS) return;

    await _liveActivities.init(
      appGroupId: 'group.ductran.ftel.fitness.onu',
      urlScheme: 'ftelfitness',
    );

    // Listen for URL scheme callbacks from Live Activity buttons
    _urlSchemeSubscription = _liveActivities.urlSchemeStream().listen((data) {
      final url = data.url ?? '';
      if (url.contains('break')) {
        onBreakToggled?.call();
      } else if (url.contains('complete')) {
        onCompleted?.call();
      }
    });
  }

  Future<void> startActivity(DateTime startTime) async {
    if (!Platform.isIOS) return;

    try {
      final enabled = await _liveActivities.areActivitiesEnabled();
      if (!enabled) {
        debugPrint('Live Activities not enabled by user');
        return;
      }

      // Generate a unique activity ID
      final activityId = 'workout_${startTime.millisecondsSinceEpoch}';

      _currentActivityId = await _liveActivities.createActivity(
        activityId,
        <String, dynamic>{
          'elapsedSeconds': 0,
          'isOnBreak': false,
        },
        removeWhenAppIsKilled: false,
      );
    } catch (e) {
      // Live Activity failed - Widget Extension may not be set up
      debugPrint('Live Activity start failed (Widget Extension may not be configured): $e');
      _currentActivityId = null;
    }
  }

  Future<void> updateActivity(Duration elapsed, {bool isOnBreak = false}) async {
    if (!Platform.isIOS || _currentActivityId == null) return;

    try {
      await _liveActivities.updateActivity(
        _currentActivityId!,
        <String, dynamic>{
          'elapsedSeconds': elapsed.inSeconds,
          'isOnBreak': isOnBreak,
        },
      );
    } catch (e) {
      debugPrint('Live Activity update failed: $e');
    }
  }

  Future<void> endActivity() async {
    if (!Platform.isIOS || _currentActivityId == null) return;

    try {
      await _liveActivities.endActivity(_currentActivityId!);
    } catch (e) {
      debugPrint('Live Activity end failed: $e');
    }
    _currentActivityId = null;
  }

  Future<void> endAllActivities() async {
    if (!Platform.isIOS) return;
    await _liveActivities.endAllActivities();
  }

  Future<bool> areActivitiesEnabled() async {
    if (!Platform.isIOS) return false;
    return await _liveActivities.areActivitiesEnabled();
  }

  void dispose() {
    _urlSchemeSubscription?.cancel();
  }
}
