import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/workout_quality.dart';

class QualityBadge extends StatelessWidget {
  final WorkoutQuality quality;
  final double fontSize;
  final EdgeInsets padding;

  const QualityBadge({
    super.key,
    required this.quality,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: quality.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: quality.color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        quality.label,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: quality.color,
        ),
      ),
    );
  }
}
