import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.kg,
    this.bisetWith,
  });

  @HiveField(0) String name;
  @HiveField(1) int sets;
  @HiveField(2) int reps;
  @HiveField(3) double kg;

  /// Index (within the same routine/session) of the primary exercise this one
  /// is paired with as a biset. Null when not part of a biset.
  @HiveField(4) int? bisetWith;
}