# Carrinho

Status: ✅ Concluído · Commit: `4ded4eb`

## Arquitetura

- DTOs: `CartItemRequestDto`, `CartItemUpdateRequestDto`,
  `ProductVariantResponseDto`.
- Domain: entidades de carrinho, `CartRepository`, usecases
  get/add/update/remove.
- `CartPage` (rota `/cart`): lista de itens, editar quantidade, remover
  item, subtotal.
- `ProductDetailPage` liga o botão "Adicionar ao carrinho" ao
  `AddCartItemUseCase` real (usa `defaultVariantId` da variante ativa e
  `pricingUnitMin` como quantidade inicial), invalida `cartProvider` após
  sucesso para refletir o novo item.

## Endpoints usados

`GET/DELETE /cart`, `POST /cart/items`, `PATCH/DELETE /cart/items/{itemId}`,
`POST /cart/merge`.
