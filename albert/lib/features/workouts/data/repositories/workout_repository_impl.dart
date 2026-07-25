import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  void _showLocalOnlyNotice() {
    try {
      if (Get.context != null) {
        Get.snackbar(
          'workouts_remote_save_error_title'.tr,
          'workouts_remote_save_error'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2C2C2E),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('Could not show snackbar: $e');
    }
  }

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
    } catch (_) {
      return Left(CacheFailure());
    }

    if (await networkInfo.isConnected) {
      try {
        await remote.addWorkout(model);
        debugPrint('Workout log synced to Firestore for workout ID: ${workout.id}');
      } catch (e) {
        debugPrint('Error saving workout remotely to Firestore: $e');
        _showLocalOnlyNotice();
      }
    } else {
      _showLocalOnlyNotice();
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteWorkout(String id) async {
    try {
      await local.deleteWorkout(id);
    } catch (_) {
      return Left(CacheFailure());
    }

    if (await networkInfo.isConnected) {
      try {
        await remote.deleteWorkout(id);
        debugPrint('Workout log deleted from Firestore for ID: $id');
      } catch (e) {
        debugPrint('Error deleting workout remotely from Firestore: $e');
        _showLocalOnlyNotice();
      }
    } else {
      _showLocalOnlyNotice();
    }
    return const Right(null);
  }
}
