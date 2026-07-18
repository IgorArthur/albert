import 'package:hive/hive.dart';
import '../../domain/models/user_profile.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfile?> getCachedProfile();
  Future<void> cacheProfile(UserProfile profile);
  Future<void> clearCache();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final Box boxAuth;
  ProfileLocalDataSourceImpl(this.boxAuth);

  @override
  Future<UserProfile?> getCachedProfile() async {
    final user = boxAuth.get('user');
    if (user != null && user is Map) {
      final height = boxAuth.get('height') ?? 180.0;
      final weight = boxAuth.get('weight') ?? 75.0;
      final savedBirthday = user['birthday'] ?? boxAuth.get('birthday');
      final dob = savedBirthday != null ? DateTime.tryParse(savedBirthday) : null;

      return UserProfile(
        uid: user['uid'] ?? '',
        email: user['email'] ?? '',
        displayName: user['displayName'] ?? 'Athlete',
        photoUrl: user['photoURL'] ?? '',
        avatar: user['avatar'] ?? '💪',
        heightCm: height,
        weightKg: weight,
        dateOfBirth: dob,
      );
    }
    return null;
  }

  @override
  Future<void> cacheProfile(UserProfile profile) async {
    await boxAuth.put('user', {
      'uid': profile.uid,
      'email': profile.email,
      'displayName': profile.displayName,
      'photoURL': profile.photoUrl,
      'avatar': profile.avatar,
      'birthday': profile.dateOfBirth?.toIso8601String(),
    });
    await boxAuth.put('height', profile.heightCm);
    await boxAuth.put('weight', profile.weightKg);
  }

  @override
  Future<void> clearCache() async {
    await boxAuth.delete('user');
    await boxAuth.delete('height');
    await boxAuth.delete('weight');
    await boxAuth.delete('birthday');
  }
}
