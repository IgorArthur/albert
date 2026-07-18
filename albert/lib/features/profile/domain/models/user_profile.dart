class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String avatar;
  final double heightCm;
  final double weightKg;
  final DateTime? dateOfBirth;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.avatar,
    required this.heightCm,
    required this.weightKg,
    this.dateOfBirth,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? avatar,
    double? heightCm,
    double? weightKg,
    DateTime? dateOfBirth,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      avatar: avatar ?? this.avatar,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
