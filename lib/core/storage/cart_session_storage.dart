import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persiste o id de sessão do carrinho anônimo (header `X-Cart-Session-Id`),
/// usado pela API para manter o carrinho de quem ainda não fez login. É
/// gerado uma única vez por instalação e associado à conta via
/// `POST /cart/merge` assim que o login é concluído — ver
/// `MergeCartUseCase`.
class CartSessionStorage {
  CartSessionStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionIdKey = 'happfest.cart_session_id';

  final FlutterSecureStorage _storage;

  Future<String> readOrCreateSessionId() async {
    final existing = await _storage.read(key: _sessionIdKey);
    if (existing != null) return existing;

    final generated = _generateUuidV4();
    await _storage.write(key: _sessionIdKey, value: generated);
    return generated;
  }

  Future<void> clear() => _storage.delete(key: _sessionIdKey);

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
