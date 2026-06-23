class ExerciseModel {
  String name;
  int sets;
  int reps;
  double weight;

  ExerciseModel({
    required this.name,
    this.sets = 3,
    this.reps = 10,
    this.weight = 0,
  });

  ExerciseModel.clone(ExerciseModel source)
      : name = source.name,
        sets = source.sets,
        reps = source.reps,
        weight = source.weight;
}

class WorkoutRoutine {
  final String id;
  final String name;
  final String icon; // Emoji icon, e.g. 🔥, ⚡, 🦵
  final List<ExerciseModel> exercises;

  WorkoutRoutine({
    required this.id,
    required this.name,
    required this.icon,
    required this.exercises,
  });

  int get totalSets => exercises.fold(0, (sum, item) => sum + item.sets);
}
