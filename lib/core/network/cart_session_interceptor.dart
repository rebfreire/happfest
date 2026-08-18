import 'package:dio/dio.dart';
import 'package:happfest/core/storage/cart_session_storage.dart';

/// Injeta `X-Cart-Session-Id` em toda chamada para `/cart*`. Necessário
/// mesmo quando o usuário está logado (o Bearer identifica o carrinho do
/// usuário) porque `POST /cart/merge` exige o header para saber qual
/// carrinho anônimo associar à conta.
class CartSessionInterceptor extends Interceptor {
  CartSessionInterceptor(this._cartSessionStorage);

  final CartSessionStorage _cartSessionStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.startsWith('/cart')) {
      final sessionId = await _cartSessionStorage.readOrCreateSessionId();
      options.headers['X-Cart-Session-Id'] = sessionId;
    }
    handler.next(options);
  }
}
