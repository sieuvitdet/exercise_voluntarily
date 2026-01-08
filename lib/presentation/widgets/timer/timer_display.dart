import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/duration_utils.dart';

class TimerDisplay extends StatelessWidget {
  final Duration duration;
  final bool isOnBreak;
  final double fontSize;

  const TimerDisplay({
    super.key,
    required this.duration,
    this.isOnBreak = false,
    this.fontSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: isOnBreak ? AppColors.accent : AppColors.textPrimary,
            letterSpacing: 4,
          ),
          child: Text(
            DurationUtils.formatMMSS(duration),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            key: ValueKey(isOnBreak),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isOnBreak
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOnBreak ? 'ON BREAK' : 'ACTIVE',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isOnBreak ? AppColors.accent : AppColors.secondary,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
