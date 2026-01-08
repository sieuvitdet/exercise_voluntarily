import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../blocs/workout_timer/workout_timer_bloc.dart';
import '../../blocs/workout_timer/workout_timer_event.dart';
import '../../blocs/workout_timer/workout_timer_state.dart';
import '../../blocs/workout_history/workout_history_bloc.dart';
import '../../blocs/workout_history/workout_history_event.dart';
import '../../blocs/statistics/statistics_bloc.dart';
import '../../blocs/statistics/statistics_event.dart';
import '../widgets/common/gradient_background.dart';
import '../widgets/timer/timer_display.dart';
import '../widgets/timer/break_button.dart';
import '../widgets/timer/complete_button.dart';

class WorkoutTimerScreen extends StatelessWidget {
  const WorkoutTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkoutTimerBloc, WorkoutTimerState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == WorkoutStatus.completed,
      listener: (context, state) {
        // Refresh history and statistics when workout completes
        context.read<WorkoutHistoryBloc>().add(const WorkoutHistoryRefreshed());
        context.read<StatisticsBloc>().add(const StatisticsRefreshed());

        // Show completion message and navigate back
        _showCompletionDialog(context, state);
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _showExitConfirmation(context);
          }
        },
        child: Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildHeader(context),
                    const Spacer(flex: 2),
                    _buildTimerSection(),
                    const Spacer(flex: 2),
                    _buildControls(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _showExitConfirmation(context),
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.textSecondary,
            size: 28,
          ),
        ),
        BlocBuilder<WorkoutTimerBloc, WorkoutTimerState>(
          buildWhen: (previous, current) => previous.quality != current.quality,
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: state.quality.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.quality.color.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: state.quality.color,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.quality.label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: state.quality.color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 48), // Balance the close button
      ],
    );
  }

  Widget _buildTimerSection() {
    return BlocBuilder<WorkoutTimerBloc, WorkoutTimerState>(
      builder: (context, state) {
        return Column(
          children: [
            Text(
              state.isOnBreak ? AppStrings.onBreak : AppStrings.workoutActive,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            TimerDisplay(
              duration: state.elapsed,
              isOnBreak: state.isOnBreak,
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls() {
    return BlocBuilder<WorkoutTimerBloc, WorkoutTimerState>(
      builder: (context, state) {
        return Column(
          children: [
            BreakButton(
              isOnBreak: state.isOnBreak,
              onPressed: () {
                context
                    .read<WorkoutTimerBloc>()
                    .add(const WorkoutBreakToggled());
              },
            ),
            const SizedBox(height: 16),
            CompleteButton(
              isLoading: state.isSaving,
              onPressed: () {
                context.read<WorkoutTimerBloc>().add(const WorkoutCompleted());
              },
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Cancel Workout?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Your progress will not be saved.',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Keep Going',
              style: GoogleFonts.poppins(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkoutTimerBloc>().add(const WorkoutCancelled());
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel Workout',
              style: GoogleFonts.poppins(
                color: AppColors.qualityCasual,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, WorkoutTimerState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.celebration_rounded,
              color: state.quality.color,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Great Job!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout completed!',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: state.quality.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        state.formattedTime,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: state.quality.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      state.quality.label,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<WorkoutTimerBloc>().add(const WorkoutReset());
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Done',
              style: GoogleFonts.poppins(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
