import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/workout.dart';

class HistoryBarChart extends StatefulWidget {
  final List<Workout> workouts;
  final int daysToShow;

  const HistoryBarChart({
    super.key,
    required this.workouts,
    this.daysToShow = 30,
  });

  @override
  State<HistoryBarChart> createState() => _HistoryBarChartState();
}

class _HistoryBarChartState extends State<HistoryBarChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final dates = AppDateUtils.getLast30Days();
    final workoutMap = _createWorkoutMap();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 30 Days',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 60,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surface,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = dates[group.x];
                    final workout = workoutMap[_formatDate(date)];
                    if (workout == null) return null;

                    return BarTooltipItem(
                      '${AppDateUtils.formatShortDate(date)}\n',
                      GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: '${workout.duration.inMinutes} min',
                          style: GoogleFonts.poppins(
                            color: workout.quality.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                touchCallback: (event, response) {
                  setState(() {
                    if (response?.spot != null &&
                        event is! FlPointerExitEvent) {
                      touchedIndex = response!.spot!.touchedBarGroupIndex;
                    } else {
                      touchedIndex = null;
                    }
                  });
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index % 7 != 0) return const SizedBox.shrink();
                      if (index >= dates.length) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          AppDateUtils.formatDay(dates[index]),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value % 20 != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${value.toInt()}m',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                    reservedSize: 32,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(dates, workoutMap),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, Workout> _createWorkoutMap() {
    final map = <String, Workout>{};
    for (final workout in widget.workouts) {
      final dateKey = _formatDate(workout.date);
      if (!map.containsKey(dateKey) ||
          workout.duration > map[dateKey]!.duration) {
        map[dateKey] = workout;
      }
    }
    return map;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<BarChartGroupData> _buildBarGroups(
    List<DateTime> dates,
    Map<String, Workout> workoutMap,
  ) {
    return List.generate(dates.length, (index) {
      final dateKey = _formatDate(dates[index]);
      final workout = workoutMap[dateKey];
      final isTouched = touchedIndex == index;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: workout?.duration.inMinutes.toDouble() ?? 0,
            color: workout?.quality.color ??
                AppColors.textSecondary.withValues(alpha: 0.2),
            width: isTouched ? 10 : 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 60,
              color: AppColors.textSecondary.withValues(alpha: 0.05),
            ),
          ),
        ],
      );
    });
  }
}
