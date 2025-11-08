import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/error/exceptions.dart';

abstract class SecureStorageDataSource {
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearAll();
}

class SecureStorageDataSourceImpl implements SecureStorageDataSource {
  final FlutterSecureStorage secureStorage;

  static const String _userIdKey = 'user_id';
  static const String _tokenKey = 'auth_token';

  SecureStorageDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveUserId(String userId) async {
    try {
      await secureStorage.write(key: _userIdKey, value: userId);
    } catch (e) {
      throw CacheException('Failed to save user ID');
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return await secureStorage.read(key: _userIdKey);
    } catch (e) {
      throw CacheException('Failed to get user ID');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw CacheException('Failed to save token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw CacheException('Failed to get token');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await secureStorage.deleteAll();
    } catch (e) {
      throw CacheException('Failed to clear storage');
    }
  }
}