import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_profile.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile?> fetchProfile(String uid);
  Future<void> uploadProfile(UserProfile profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore? _firestore;
  ProfileRemoteDataSourceImpl([this._firestore]);

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('users');

  @override
  Future<UserProfile?> fetchProfile(String uid) async {
    if (uid.isEmpty) return null;
    final doc = await _collection.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfileModel.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> uploadProfile(UserProfile profile) async {
    if (profile.uid.isEmpty) return;
    final model = UserProfileModel.fromEntity(profile);
    await _collection.doc(profile.uid).set(model.toJson());
  }
}
