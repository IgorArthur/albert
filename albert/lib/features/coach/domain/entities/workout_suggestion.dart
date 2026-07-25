import 'package:equatable/equatable.dart';

class WorkoutSuggestion extends Equatable {
  final String exerciseName;
  final int sets;
  final int reps;
  final String reasoning;

  const WorkoutSuggestion({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.reasoning,
  });

  @override
  List<Object?> get props => [exerciseName, sets, reps, reasoning];
}
