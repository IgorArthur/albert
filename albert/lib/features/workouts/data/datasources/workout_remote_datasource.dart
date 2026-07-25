import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_model.dart';

abstract class WorkoutRemoteDataSource {
  Future<List<WorkoutModel>> getWorkouts();
  Future<void> addWorkout(WorkoutModel workout);
  Future<void> deleteWorkout(String id);
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final FirebaseFirestore? _firestore;
  WorkoutRemoteDataSourceImpl([this._firestore]);

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return firestore.collection('workouts');
    }
    return firestore.collection('users').doc(uid).collection('workouts');
  }

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
