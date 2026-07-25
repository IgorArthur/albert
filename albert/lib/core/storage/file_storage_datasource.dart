import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../error/exceptions.dart';

abstract class FileStorageDataSource {
  /// Uploads a file and returns its public download URL.
  Future<String> uploadFile({
    required File file,
    required String path, // e.g. 'workout_photos/<userId>/<workoutId>.jpg'
  });

  Future<void> deleteFile(String path);
}

class FileStorageDataSourceImpl implements FileStorageDataSource {
  final FirebaseStorage storage;
  FileStorageDataSourceImpl(this.storage);

  @override
  Future<String> uploadFile({required File file, required String path}) async {
    try {
      final ref = storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      await storage.ref().child(path).delete();
    } catch (_) {
      throw ServerException();
    }
  }
}
