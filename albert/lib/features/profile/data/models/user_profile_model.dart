import '../../domain/models/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.photoUrl,
    required super.avatar,
    required super.heightCm,
    required super.weightKg,
    super.dateOfBirth,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '💪',
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 180.0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 75.0,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'avatar': avatar,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      uid: profile.uid,
      email: profile.email,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      avatar: profile.avatar,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      dateOfBirth: profile.dateOfBirth,
    );
  }
}
