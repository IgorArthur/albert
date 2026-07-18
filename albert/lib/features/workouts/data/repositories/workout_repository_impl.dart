import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';
import '../datasources/workout_remote_datasource.dart';
import '../models/workout_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource remote;
  final WorkoutLocalDataSource local;
  final NetworkInfo networkInfo;

  WorkoutRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Workout>>> getWorkouts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteWorkouts = await remote.getWorkouts();
        await local.cacheWorkouts(remoteWorkouts);
        return Right(remoteWorkouts);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final cached = await local.getCachedWorkouts();
        return Right(cached);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, void>> addWorkout(Workout workout) async {
    final model = WorkoutModel.fromEntity(workout);
    try {
      await local.addWorkout(model);
      if (await networkInfo.isConnected) {
        await remote.addWorkout(model);
      }
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkout(String id) async {
    try {
      await local.deleteWorkout(id);
      if (await networkInfo.isConnected) {
        await remote.deleteWorkout(id);
      }
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
