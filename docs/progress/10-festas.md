# Festas

Status: ✅ Concluído

## Arquitetura

- `feature/parties`: DTOs `PartyResponseDto`/`PartyRequestDto`, domain
  `Party`/`PartyStatus`, `PartyRepository.getParties(customerId)` /
  `.createParty(...)`.
- [`PartiesPage`](../../lib/features/parties/presentation/pages/parties_page.dart)
  (rota `/festas`): lista as festas do cliente logado, FAB para cadastrar
  uma nova.
- [`NewPartyPage`](../../lib/features/parties/presentation/pages/new_party_page.dart)
  (rota `/festas/novo`): usa
  [`CepAddressFields`](../../lib/core/location/cep_address_fields.dart)
  (mesmo componente do endereço) + seleção de datas de início/fim + número
  de convidados.
- `partiesProvider` depende do `customerId` obtido via
  `accountContextProvider` (feature de Conta) — a API exige o id do
  customer na URL.

## Endpoints usados

`GET/POST /customers/{customerId}/parties`.

## Pendência

A API não expõe `PUT`/`DELETE` para festas — só criar e listar são
possíveis nesse contrato; editar/arquivar uma festa não tem endpoint.
