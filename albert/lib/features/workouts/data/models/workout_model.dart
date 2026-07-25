// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import '../../domain/entities/workout.dart';

part 'workout_model.g.dart';

@HiveType(typeId: 3)
class WorkoutModel extends Workout {
  @HiveField(0) @override final String id;
  @HiveField(1) @override final String exerciseName;
  @HiveField(2) @override final int sets;
  @HiveField(3) @override final int reps;
  @HiveField(4) @override final double weightKg;
  @HiveField(5) @override final DateTime date;
  @HiveField(6) @override final String? photoUrl;

  const WorkoutModel({
    required this.id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weightKg,
    required this.date,
    this.photoUrl,
  }) : super(
          id: id,
          exerciseName: exerciseName,
          sets: sets,
          reps: reps,
          weightKg: weightKg,
          date: date,
          photoUrl: photoUrl,
        );

  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
        id: json['id'] as String,
        exerciseName: json['exerciseName'] as String,
        sets: json['sets'] as int,
        reps: json['reps'] as int,
        weightKg: (json['weightKg'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        photoUrl: json['photoUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseName': exerciseName,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
        'date': date.toIso8601String(),
        'photoUrl': photoUrl,
      };

  factory WorkoutModel.fromEntity(Workout w) => WorkoutModel(
        id: w.id,
        exerciseName: w.exerciseName,
        sets: w.sets,
        reps: w.reps,
        weightKg: w.weightKg,
        date: w.date,
        photoUrl: w.photoUrl,
      );
}
