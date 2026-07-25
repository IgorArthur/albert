import 'package:albert/core/error/exceptions.dart';
import 'package:albert/core/error/failures.dart';
import 'package:albert/core/network/network_info.dart';
import 'package:albert/features/workouts/data/datasources/workout_local_datasource.dart';
import 'package:albert/features/workouts/data/datasources/workout_remote_datasource.dart';
import 'package:albert/features/workouts/data/models/workout_model.dart';
import 'package:albert/features/workouts/data/repositories/workout_repository_impl.dart';
import 'package:albert/features/workouts/domain/entities/workout.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutRemoteDataSource extends Mock implements WorkoutRemoteDataSource {}
class MockWorkoutLocalDataSource extends Mock implements WorkoutLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late WorkoutRepositoryImpl repository;
  late MockWorkoutRemoteDataSource mockRemote;
  late MockWorkoutLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemote = MockWorkoutRemoteDataSource();
    mockLocal = MockWorkoutLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = WorkoutRepositoryImpl(
      remote: mockRemote,
      local: mockLocal,
      networkInfo: mockNetworkInfo,
    );
  });

  final tWorkoutModel = WorkoutModel(
    id: '1',
    exerciseName: 'Squat',
    sets: 3,
    reps: 10,
    weightKg: 100.0,
    date: DateTime(2026, 7, 18),
  );
  final List<WorkoutModel> tWorkoutModels = [tWorkoutModel];
  final List<Workout> tWorkouts = tWorkoutModels;

  setUpAll(() {
    registerFallbackValue(tWorkoutModel);
  });

  group('getWorkouts', () {
    test('should check if the device is online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.getWorkouts()).thenAnswer((_) async => tWorkoutModels);
      when(() => mockLocal.cacheWorkouts(any())).thenAnswer((_) async => {});

      await repository.getWorkouts();

      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return remote data when getWorkouts is successful and cache it locally', () async {
        when(() => mockRemote.getWorkouts()).thenAnswer((_) async => tWorkoutModels);
        when(() => mockLocal.cacheWorkouts(any())).thenAnswer((_) async => {});

        final result = await repository.getWorkouts();

        verify(() => mockRemote.getWorkouts());
        verify(() => mockLocal.cacheWorkouts(tWorkoutModels));
        expect(result, equals(Right(tWorkouts)));
      });

      test('should return ServerFailure when remote getWorkouts fails', () async {
        when(() => mockRemote.getWorkouts()).thenThrow(ServerException());

        final result = await repository.getWorkouts();

        verify(() => mockRemote.getWorkouts());
        expect(result, equals(Left(ServerFailure())));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return local cached data when cache is present', () async {
        when(() => mockLocal.getCachedWorkouts()).thenAnswer((_) async => tWorkoutModels);

        final result = await repository.getWorkouts();

        verifyZeroInteractions(mockRemote);
        verify(() => mockLocal.getCachedWorkouts());
        expect(result, equals(Right(tWorkouts)));
      });

      test('should return CacheFailure when local cache fails', () async {
        when(() => mockLocal.getCachedWorkouts()).thenThrow(CacheException());

        final result = await repository.getWorkouts();

        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('addWorkout', () {
    test('should save to local and remote when online', () async {
      when(() => mockLocal.addWorkout(any())).thenAnswer((_) async => {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.addWorkout(any())).thenAnswer((_) async => {});

      final result = await repository.addWorkout(tWorkoutModel);

      verify(() => mockLocal.addWorkout(any()));
      verify(() => mockRemote.addWorkout(any()));
      expect(result, equals(const Right(null)));
    });

    test('should save only to local when offline', () async {
      when(() => mockLocal.addWorkout(any())).thenAnswer((_) async => {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.addWorkout(tWorkoutModel);

      verify(() => mockLocal.addWorkout(any()));
      verifyZeroInteractions(mockRemote);
      expect(result, equals(const Right(null)));
    });

    test('should save to local and return Right(null) when remote save fails', () async {
      when(() => mockLocal.addWorkout(any())).thenAnswer((_) async => {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.addWorkout(any())).thenThrow(ServerException());

      final result = await repository.addWorkout(tWorkoutModel);

      verify(() => mockLocal.addWorkout(any()));
      verify(() => mockRemote.addWorkout(any()));
      expect(result, equals(const Right(null)));
    });

    test('should return CacheFailure when local save fails', () async {
      when(() => mockLocal.addWorkout(any())).thenThrow(CacheException());

      final result = await repository.addWorkout(tWorkoutModel);

      verify(() => mockLocal.addWorkout(any()));
      expect(result, equals(Left(CacheFailure())));
    });
  });

  group('deleteWorkout', () {
    test('should delete from local and remote when online', () async {
      when(() => mockLocal.deleteWorkout(any())).thenAnswer((_) async => {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.deleteWorkout(any())).thenAnswer((_) async => {});

      final result = await repository.deleteWorkout('1');

      verify(() => mockLocal.deleteWorkout('1'));
      verify(() => mockRemote.deleteWorkout('1'));
      expect(result, equals(const Right(null)));
    });

    test('should delete only from local when offline', () async {
      when(() => mockLocal.deleteWorkout(any())).thenAnswer((_) async => {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.deleteWorkout('1');

      verify(() => mockLocal.deleteWorkout('1'));
      verifyZeroInteractions(mockRemote);
      expect(result, equals(const Right(null)));
    });

    test('should delete from local and return Right(null) when remote delete fails', () async {
      when(() => mockLocal.deleteWorkout(any())).thenAnswer((_) async => {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.deleteWorkout(any())).thenThrow(ServerException());

      final result = await repository.deleteWorkout('1');

      verify(() => mockLocal.deleteWorkout('1'));
      verify(() => mockRemote.deleteWorkout('1'));
      expect(result, equals(const Right(null)));
    });

    test('should return CacheFailure when local delete fails', () async {
      when(() => mockLocal.deleteWorkout(any())).thenThrow(CacheException());

      final result = await repository.deleteWorkout('1');

      verify(() => mockLocal.deleteWorkout('1'));
      expect(result, equals(Left(CacheFailure())));
    });
  });
}
