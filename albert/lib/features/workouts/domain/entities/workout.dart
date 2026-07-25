import 'package:equatable/equatable.dart';

class Workout extends Equatable {
  final String id;
  final String exerciseName;
  final int sets;
  final int reps;
  final double weightKg;
  final DateTime date;
  final String? photoUrl; // reference to a file in Firebase Storage, not the file itself

  const Workout({
    required this.id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weightKg,
    required this.date,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, exerciseName, sets, reps, weightKg, date, photoUrl];
}
