import 'package:equatable/equatable.dart';

sealed class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class StatisticsLoaded extends StatisticsEvent {
  const StatisticsLoaded();
}

class StatisticsRefreshed extends StatisticsEvent {
  const StatisticsRefreshed();
}
