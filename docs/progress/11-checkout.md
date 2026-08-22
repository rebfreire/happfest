# Checkout

Status: ✅ Concluído (código) · ⚠️ Ainda não validado ao vivo no simulador

## Arquitetura

- `feature/checkout`: DTOs (`CheckoutPreviewRequest/Response`,
  `CheckoutRequest/Response`, `SubOrderPreviewResponse`,
  `PreviewItemResponse`, `OrderResponse`, `PaymentResponse`), domain
  (`CheckoutPreview`, `CheckoutResult`, `PaymentMethod`),
  `CheckoutRepository`, `PreviewCheckoutUseCase`, `SubmitCheckoutUseCase`.
- [`CheckoutPage`](../../lib/features/checkout/presentation/pages/checkout_page.dart):
  4 passos controlados por `checkoutFlowProvider` (Riverpod), replicando o
  fluxo do site (Itens → Festa → Entrega → Resumo):
  - **Itens**: reaproveita o carrinho (somente leitura).
  - **Festa**: lista/seleciona festa do cliente; atalho para cadastrar uma
    nova (`/festas/novo`).
  - **Entrega**: informativo — todas as lojas herdam a entrega da festa
    selecionada (comportamento padrão da API quando `deliveries` não é
    enviado no checkout). Sem override por loja nesta versão.
  - **Resumo**: `POST /orders/checkout/preview` (breakdown por loja +
    total), seleção de forma de pagamento (Pix/Cartão/Boleto),
    `POST /orders/checkout` ao confirmar.
- [`OrderConfirmationPage`](../../lib/features/checkout/presentation/pages/order_confirmation_page.dart):
  mostra o resultado e abre o `paymentLink` retornado pela API via
  `url_launcher` (navegador externo) — o app **nunca** coleta dados de
  cartão diretamente, a gateway de pagamento cuida disso via link.
- Botão "Finalizar compra" no [`CartPage`](../../lib/features/cart/presentation/pages/cart_page.dart)
  leva a `/checkout`.

## Endpoints usados

`POST /orders/checkout/preview`, `POST /orders/checkout`.

## Pendências

- Sem edição de entrega por loja (data/hora/endereço individual) — todas
  herdam da festa. Precisa de UI adicional por `SubOrderDeliveryRequest`.
- Fluxo ainda não confirmado ao vivo contra a API real (só testado via
  unit tests dos usecases/repository).
