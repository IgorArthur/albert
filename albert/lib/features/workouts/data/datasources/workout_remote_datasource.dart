import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_model.dart';

abstract class WorkoutRemoteDataSource {
  Future<List<WorkoutModel>> getWorkouts();
  Future<void> addWorkout(WorkoutModel workout);
  Future<void> deleteWorkout(String id);
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final FirebaseFirestore firestore;
  WorkoutRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('workouts');

  @override
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      final snap = await _collection.get();
      return snap.docs.map((d) => WorkoutModel.fromJson(d.data())).toList();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> addWorkout(WorkoutModel workout) =>
      _collection.doc(workout.id).set(workout.toJson());

  @override
  Future<void> deleteWorkout(String id) => _collection.doc(id).delete();
}
