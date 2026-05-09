import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {

  static const _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> clearTokens() async{
    await _storage.deleteAll();
  }


}