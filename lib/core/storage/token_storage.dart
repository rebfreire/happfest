import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the auth token in the platform Keychain/EncryptedSharedPreferences.
/// Never store tokens in SharedPreferences — see AGENTS.md seção 9.
///
/// A API HappFest expõe um único token por login (`LoginResponse.token`);
/// `POST /auth/refresh?token=...` troca esse token por um novo — não há um
/// refresh token separado no contrato atual.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'happfest.token';

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
