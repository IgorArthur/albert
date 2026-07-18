import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<UserProfile?> getProfile() async {
    // 1. Check local cache first (offline-first strategy)
    final cached = await localDataSource.getCachedProfile();
    if (cached != null) {
      // 2. Fetch from remote in background or on stale cache
      try {
        final remote = await remoteDataSource.fetchProfile(cached.uid);
        if (remote != null) {
          await localDataSource.cacheProfile(remote);
          return remote;
        }
      } catch (_) {
        // Suppress remote errors and serve local cache
      }
      return cached;
    }
    return null;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    // 1. Cache locally first
    await localDataSource.cacheProfile(profile);
    // 2. Upload to remote backend API
    try {
      await remoteDataSource.uploadProfile(profile);
    } catch (_) {
      // In production, queue synchronization if offline
    }
  }

  @override
  Future<void> clearProfile() async {
    await localDataSource.clearCache();
  }
}
