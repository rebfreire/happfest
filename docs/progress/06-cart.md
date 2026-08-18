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

## Carrinho anônimo (2026-08-18)

A API suporta carrinho sem login via header `X-Cart-Session-Id` (visto no
`docs/api/openapi.json`, opcional em todos os endpoints de carrinho e
obrigatório em `/cart/merge`). Implementado:

- [`CartSessionStorage`](../../lib/core/storage/cart_session_storage.dart):
  gera um UUID v4 uma única vez por instalação (Keychain via
  `flutter_secure_storage`, mesmo padrão do `TokenStorage`) e persiste.
- [`CartSessionInterceptor`](../../lib/core/network/cart_session_interceptor.dart):
  injeta `X-Cart-Session-Id` automaticamente em toda chamada `/cart*` —
  nenhum repositório precisa saber do header.
- `CartRepository.mergeAnonymousCart()` / `MergeCartUseCase` →
  `POST /cart/merge`.
- [`LoginController.submit()`](../../lib/features/auth/presentation/controllers/login_controller.dart):
  no login bem-sucedido, chama o merge (best-effort — uma falha no merge
  não impede o login) e invalida `cartProvider`.
- `AuthRepositoryImpl.logout()` limpa o session id junto com o token, para
  o próximo uso do dispositivo começar um carrinho anônimo novo.

Efeito prático: itens adicionados ao carrinho **antes** do login não se
perdem — são associados à conta assim que o login é concluído.
