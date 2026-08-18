# Detalhe do Produto

Status: ✅ Concluído · Commit: `bb56e39`

## Arquitetura

- `ProductImageResponseDto` (freezed) para `GET /products/{id}/images`.
- `ProductDetail` (entity freezed) combina produto + imagens + variantes
  ativas; expõe `defaultVariantId` (primeira variante ativa) e
  `pricingUnitLabel`/`pricingUnitMin`/`pricingUnitMax` (nullable).
- `ProductDetailRepositoryImpl` busca produto, imagens e variantes em
  paralelo via `Future.wait`.
- `ProductDetailPage`: galeria de imagens, nome, badge PRODUTO/SERVIÇO, nome
  da loja, preço (ou faixa de preço), descrição, botão "Adicionar ao
  carrinho".

## Rota

`/products/:id` — aceita `storeName` opcional via `extra` (evita nova
chamada de API quando já se sabe o nome da loja, ex.: vindo da Home).
