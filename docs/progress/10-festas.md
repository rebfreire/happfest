# Festas

Status: ✅ Concluído (leitura) · ⚠️ Criação não implementada

## Arquitetura

- `feature/parties`: DTO `PartyResponseDto`, domain `Party`/`PartyStatus`,
  `PartyRepository.getParties(customerId)`.
- [`PartiesPage`](../../lib/features/parties/presentation/pages/parties_page.dart)
  (rota `/festas`): lista as festas do cliente logado (nome, período,
  cidade/UF, nº de convidados, badge "ARQUIVADA" quando aplicável).
- `partiesProvider` depende do `customerId` obtido via
  `accountContextProvider` (feature de Conta) — a API exige o id do
  customer na URL (`GET /customers/{customerId}/parties`).

## Endpoints usados

`GET /customers/{customerId}/parties`.

## Pendência

Criar festa (`POST /customers/{customerId}/parties`) exige
`cityCodigoIbge`/`stateCodigoUf`, mesma limitação documentada em
`docs/progress/09-conta.md` — sem seletor de cidade/UF, fica para depois.
