# Checkout

Status: ✅ Concluído (código) · ⚠️ Ainda não validado ao vivo no simulador

## Arquitetura

- `feature/checkout`: DTOs (`CheckoutPreviewRequest/Response`,
  `CheckoutRequest/Response`, `SubOrderPreviewResponse`,
  `PreviewItemResponse`, `OrderResponse`, `PaymentResponse`,
  `PaymentActionResponse`), domain (`CheckoutPreview`, `CheckoutResult`,
  `Payment`, `PaymentAction`, `PaymentMethod`), `CheckoutRepository`,
  `PreviewCheckoutUseCase`, `SubmitCheckoutUseCase`,
  `GetPaymentStatusUseCase`.
- [`CheckoutPage`](../../lib/features/checkout/presentation/pages/checkout_page.dart):
  4 passos controlados por `checkoutFlowProvider` (Riverpod), replicando o
  fluxo do site (Itens → Festa → Entrega → Resumo):
  - **Itens**: reaproveita o carrinho (somente leitura).
  - **Festa**: lista/seleciona festa do cliente; atalho para cadastrar uma
    nova (`/festas/novo`). Trocar de festa gera uma nova
    `Idempotency-Key` (ver abaixo).
  - **Entrega**: informativo — todas as lojas herdam a entrega da festa
    selecionada (comportamento padrão da API quando `deliveries` não é
    enviado no checkout). Sem override por loja nesta versão.
  - **Resumo**: `POST /orders/checkout/preview` (breakdown por loja,
    total, desconto por forma de pagamento, saldo disponível), seleção de
    forma de pagamento (Pix/Cartão/Boleto — o preview é refeito a cada
    troca, já que o desconto varia por método), `POST /orders/checkout` ao
    confirmar.
- **Idempotência**: `checkoutFlowProvider` guarda uma `idempotencyKey`
  (`core/utils/idempotency_key.dart`, um UUID v4-like gerado localmente,
  sem depender de pacote externo) reusada em toda tentativa de
  `POST /orders/checkout` daquela festa/carrinho — enviada no header
  `Idempotency-Key`. A chave só muda quando o usuário troca de festa ou
  reinicia o fluxo (`reset()`), nunca por causa de um retry técnico da
  mesma tentativa.
- **Checkout assíncrono e polling**:
  [`OrderConfirmationPage`](../../lib/features/checkout/presentation/pages/order_confirmation_page.dart)
  recebe o `CheckoutResult` inicial (que pode vir sem `payment`, ou com
  `payment.status=PENDING` e nenhuma ação ainda) e faz polling em
  `GET /payments/order/{orderId}` a cada ~10s até um estado terminal
  (`APPROVED`/`FAILED`/`CANCELLED`/`PARTIALLY_REFUNDED`/`REFUNDED`/
  `CHARGEBACK`) ou até uma `payment.action` aparecer — parando o timer em
  qualquer um dos dois casos. Respeita `payment.expiresAt`/
  `action.expiresAt`: se o prazo já passou, para de tentar e mostra que o
  prazo expirou. **Simplificação assumida**: a API entrega
  `paymentStatusUrl`, mas hoje ele sempre corresponde a
  `GET /payments/order/{orderId}` — o app usa o `orderId` diretamente em
  vez de parsear a URL retornada.
- **Ações de pagamento**
  ([`PaymentActionView`](../../lib/features/checkout/presentation/widgets/payment_action_view.dart)):
  - `PIX`: QR code gerado localmente (`qr_flutter`) a partir do
    `pixCopyPaste`, código copia-e-cola selecionável + botão copiar,
    expiração.
  - `BOLETO`: linha digitável selecionável + botão que abre
    `boletoPdfUrl` no navegador externo.
  - `HOSTED_REDIRECT` (cartão): botão "Ir para pagamento seguro" — **nunca
    redireciona sozinho**. Ao tocar, abre
    [`HostedCheckoutPage`](../../lib/features/checkout/presentation/pages/hosted_checkout_page.dart)
    (WebView interno via `webview_flutter`), que detecta os retornos
    `.../checkout/confirmacao/{orderId}?retorno=...`, fecha sozinha e
    devolve o controle para a confirmação nativa, que então força uma
    nova consulta de status — o `retorno` na URL é só informativo, o
    estado real sempre vem da API.
  - `NONE`/ação ainda ausente: "Preparando instruções de pagamento..." +
    spinner, continua o polling.
- O app **nunca** coleta dados de cartão diretamente — a gateway de
  pagamento cuida disso via QR/boleto/checkout hospedado.
- Botão "Finalizar compra" no [`CartPage`](../../lib/features/cart/presentation/pages/cart_page.dart)
  leva a `/checkout`.

## Endpoints usados

`POST /orders/checkout/preview`, `POST /orders/checkout`,
`GET /payments/order/{orderId}`.

## Pendências

- Sem edição de entrega por loja (data/hora/endereço individual) — todas
  herdam da festa. Precisa de UI adicional por `SubOrderDeliveryRequest`.
- Checkout parcial (`cartItemIds` no preview/checkout) não tem UI — sempre
  finaliza o carrinho inteiro.
- `useBalanceAmount` (usar saldo da carteira) não tem toggle na UI — o
  preview já mostra `balanceAvailable`, mas o checkout não envia o campo.
- Fluxo ainda não confirmado ao vivo contra a API real (só testado via
  unit/widget tests dos usecases/repository/polling — ver
  `test/unit/features/checkout/` e
  `test/widget/features/checkout/order_confirmation_page_test.dart`).
