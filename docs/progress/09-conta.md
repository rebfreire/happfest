# Conta (Perfil)

Status: ✅ Concluído

## Arquitetura

- `feature/account`: DTOs `CustomerContextResponseDto`,
  `CustomerAddressResponseDto`/`CustomerAddressRequestDto`,
  `OrderSummaryResponseDto` (lista) e `OrderDetailResponseDto`/
  `SubOrderResponseDto`/`SubOrderItemResponseDto` (detalhe). Domain:
  `CustomerAccount`, `CustomerAddress`, `OrderSummary`, `OrderDetail`,
  `AccountRepository`.
- [`AccountPage`](../../lib/features/account/presentation/pages/account_page.dart)
  (rota `/perfil`): dados do cliente, endereços (criar via
  `/perfil/enderecos/novo`, excluir e definir como padrão por um menu por
  item), pedidos (toca para abrir o detalhe), botão "Sair". Pull-to-refresh
  recarrega tudo.
- [`OrderDetailPage`](../../lib/features/account/presentation/pages/order_detail_page.dart)
  (rota `/pedidos/:id`): breakdown por sub-pedido (loja), status, itens e
  subtotal.
- [`NewAddressPage`](../../lib/features/account/presentation/pages/new_address_page.dart):
  usa [`CepAddressFields`](../../lib/core/location/cep_address_fields.dart)
  — CEP resolve rua/bairro/cidade/UF automaticamente via ViaCEP; sem
  precisar escolher cidade manualmente no caminho feliz.

## Endpoints usados

`GET /customers/me/context`, `GET/POST /customers/me/addresses`,
`DELETE /customers/me/addresses/{id}`,
`PATCH /customers/me/addresses/{id}/default`, `GET /orders`,
`GET /orders/{id}`.

## Pendência

Editar endereço (`PUT /customers/me/addresses/{id}`) ainda não tem UI —
só criar/excluir/definir padrão.

## Nota sobre nullability dos DTOs

Nenhum schema de resposta da API (`docs/api/openapi.json`) declara campos
como `required` — nem o `CustomerContextResponse`. Seguindo a lição do bug
de `token: null` no login (ver `docs/progress/03-auth.md`), todos os DTOs
dessa feature tratam só `id`/`customerId` como obrigatórios; o resto é
nullable ou tem `@Default`, com fallback sensato no mapper (ex.: endereço
sem `label` vira "Endereço").
