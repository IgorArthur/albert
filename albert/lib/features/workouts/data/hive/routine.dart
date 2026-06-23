import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:hive/hive.dart';

part 'routine.g.dart';

@HiveType(typeId: 0)
class Routine extends HiveObject {
  Routine({
    required this.id,
    required this.name,
    required this.icon,
    required this.exercises,
    required this.createdAt,
  });

  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String icon;
  @HiveField(3) List<Exercise> exercises;
  @HiveField(4) DateTime createdAt;

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);
}