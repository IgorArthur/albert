import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.kg,
  });

  @HiveField(0) String name;
  @HiveField(1) int sets;
  @HiveField(2) int reps;
  @HiveField(3) double kg;
}