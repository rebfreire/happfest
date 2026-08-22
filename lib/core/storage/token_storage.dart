import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the access + refresh tokens in the platform Keychain/
/// EncryptedSharedPreferences. Never store tokens in SharedPreferences —
/// see AGENTS.md seção 9.
///
/// A API HappFest usa o fluxo `POST /auth/mobile/login` /
/// `POST /auth/mobile/refresh`: cada resposta traz um par
/// `accessToken`/`refreshToken` que substitui o par anterior por completo.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'happfest.access_token';
  static const _refreshTokenKey = 'happfest.refresh_token';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
