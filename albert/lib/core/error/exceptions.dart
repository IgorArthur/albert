class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server exception occurred']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache exception occurred']);
}
