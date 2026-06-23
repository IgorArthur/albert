import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:hive/hive.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 2)
class WorkoutSession extends HiveObject {
  WorkoutSession({
    required this.id,
    required this.routineId,
    required this.routineName,
    required this.startedAt,
    this.finishedAt,
    required this.exercises,
  });

  @HiveField(0) String id;
  @HiveField(1) String routineId;
  @HiveField(2) String routineName;
  @HiveField(3) DateTime startedAt;
  @HiveField(4) DateTime? finishedAt;
  @HiveField(5) List<Exercise> exercises;
}