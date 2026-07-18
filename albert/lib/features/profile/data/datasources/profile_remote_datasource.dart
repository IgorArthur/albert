import '../../domain/models/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile?> fetchProfile(String uid);
  Future<void> uploadProfile(UserProfile profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  // Simulates remote REST API calls (can be expanded to use a unified HTTP client later)
  @override
  Future<UserProfile?> fetchProfile(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null; // Fallback to local Hive
  }

  @override
  Future<void> uploadProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
