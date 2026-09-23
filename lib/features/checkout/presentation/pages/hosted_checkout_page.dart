import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Abre o checkout hospedado (ação `HOSTED_REDIRECT`) num WebView dentro do
/// app — nunca redireciona automaticamente, só ao toque do usuário no botão
/// "Ir para pagamento seguro". Detecta os retornos de
/// `https://happ-marketplace.comcode.com.br/checkout/confirmacao/{orderId}`
/// e fecha a tela sozinha, devolvendo o controle para a confirmação nativa —
/// o `retorno` na URL é só informativo, o estado real vem sempre da API.
class HostedCheckoutPage extends StatefulWidget {
  const HostedCheckoutPage({
    required this.url,
    required this.orderId,
    super.key,
  });

  final String url;
  final String orderId;

  static const _returnPathPrefix = '/checkout/confirmacao/';

  @override
  State<HostedCheckoutPage> createState() => _HostedCheckoutPageState();
}

class _HostedCheckoutPageState extends State<HostedCheckoutPage> {
  late final WebViewController _controller;
  var _closed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initController());
  }

  Future<void> _initController() async {
    _controller = WebViewController();
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) {
          if (_isReturnUrl(request.url)) {
            _closeToConfirmation();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    await _controller.loadRequest(Uri.parse(widget.url));
  }

  bool _isReturnUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.path.contains(
      '${HostedCheckoutPage._returnPathPrefix}${widget.orderId}',
    );
  }

  void _closeToConfirmation() {
    if (_closed) return;
    _closed = true;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento seguro'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
