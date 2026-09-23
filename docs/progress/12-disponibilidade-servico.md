# Disponibilidade de serviços agendáveis

Status: ✅ Concluído (código) · ⚠️ Ainda não validado ao vivo no simulador

## Arquitetura

- `feature/service_availability`: DTOs `ServiceAvailabilityResponseDto`/
  `ServiceAvailabilityDateResponseDto`, domain `ServiceAvailability`/
  `ServiceAvailabilityDate`, `ServiceAvailabilityRepository`,
  `GetServiceAvailabilityUseCase`.
- [`ServiceAvailabilityPicker`](../../lib/features/service_availability/presentation/widgets/service_availability_picker.dart):
  calendário (`table_calendar`) que só habilita as datas presentes em
  `availableDates`; quando `timeSelectionRequired=true`, mostra os horários
  daquela data como chips.
- [`ProductDetailPage`](../../lib/features/products/presentation/pages/product_detail_page.dart):
  para `productType=SERVICE`, mostra seletor de quantidade + duração
  (`pricingUnitQuantity`) e o `ServiceAvailabilityPicker`. Mudar
  quantidade/duração refaz a consulta (`serviceAvailabilityProvider`, uma
  `FutureProvider.family` chaveada por `(productId, quantity,
  pricingUnitQuantity)`). Sem datas disponíveis ou sem
  data/horário escolhidos, o botão "Adicionar ao carrinho" fica desabilitado.
- Ao adicionar, envia `preferredDate`/`preferredTime` em
  `POST /cart/items` junto com `productVariantId`/`quantity`/
  `pricingUnitQuantity`.
- Um `409` (conflito de agenda) ao adicionar — ou depois, no checkout —
  mapeia para `ConflictFailure` (novo em `core/error/failure.dart`), invalida
  o provider de disponibilidade para forçar nova consulta, e limpa a
  data/horário selecionados.

## Endpoints usados

`GET /products/{productId}/service-availability` (query `quantity`,
`pricingUnitQuantity`).

## Pendência

Produtos físicos (`productType=PHYSICAL`) continuam pulando essa etapa
inteiramente — o fluxo de disponibilidade só roda para `SERVICE`.
