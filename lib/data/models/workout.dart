import 'package:equatable/equatable.dart';
import 'workout_quality.dart';

class Workout extends Equatable {
  final int? id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final WorkoutQuality quality;
  final DateTime? createdAt;

  const Workout({
    this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.quality,
    this.createdAt,
  });

  factory Workout.create({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final duration = endTime.difference(startTime);
    return Workout(
      date: DateTime(startTime.year, startTime.month, startTime.day),
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      quality: WorkoutQuality.fromDuration(duration),
      createdAt: DateTime.now(),
    );
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as int,
      date: DateTime.parse(map['date'] as String),
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      duration: Duration(seconds: map['duration_seconds'] as int),
      quality: WorkoutQuality.fromString(map['quality'] as String),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': _formatDateOnly(date),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_seconds': duration.inSeconds,
      'quality': quality.name,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  String _formatDateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Workout copyWith({
    int? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    WorkoutQuality? quality,
    DateTime? createdAt,
  }) {
    return Workout(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        startTime,
        endTime,
        duration,
        quality,
        createdAt,
      ];
}
