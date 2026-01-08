class AppDurations {
  AppDurations._();

  // Quality thresholds (in minutes)
  static const int casualMaxMinutes = 10;
  static const int goodMaxMinutes = 20;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Timer interval
  static const Duration timerInterval = Duration(seconds: 1);
}
