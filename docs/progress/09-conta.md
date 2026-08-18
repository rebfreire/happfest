# Conta (Perfil)

Status: ✅ Concluído (leitura) · ⚠️ Criação/edição não implementada

## Arquitetura

- `feature/account`: DTOs `CustomerContextResponseDto`,
  `CustomerAddressResponseDto`, `OrderSummaryResponseDto` (subconjunto de
  `OrderResponse` — só os campos usados na lista). Domain: `CustomerAccount`,
  `CustomerAddress`, `OrderSummary`, `AccountRepository`.
- [`AccountPage`](../../lib/features/account/presentation/pages/account_page.dart)
  (rota `/perfil`): dados do cliente (nome/email/telefone), lista de
  endereços, lista de pedidos, botão "Sair" (logout → `/login`).
  Pull-to-refresh recarrega os três.

## Endpoints usados

`GET /customers/me/context`, `GET /customers/me/addresses`, `GET /orders`.

## Pendência

Criar/editar endereço (`POST/PUT /customers/me/addresses`) fica de fora
porque a API exige `cityCodigoIbge`/`stateCodigoUf` e não expõe endpoint de
busca desses códigos — falta um seletor de cidade/UF. Assim que essa peça
existir (própria ou via API externa do IBGE), dá para completar o CRUD.

## Nota sobre nullability dos DTOs

Nenhum schema de resposta da API (`docs/api/openapi.json`) declara campos
como `required` — nem o `CustomerContextResponse`. Seguindo a lição do bug
de `token: null` no login (ver `docs/progress/03-auth.md`), todos os DTOs
dessa feature tratam só `id`/`customerId` como obrigatórios; o resto é
nullable ou tem `@Default`, com fallback sensato no mapper (ex.: endereço
sem `label` vira "Endereço").
