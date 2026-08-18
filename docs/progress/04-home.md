# Home (Categorias + Busca de Produtos)

Status: ✅ Concluído · Commit: `b623032`

## Arquitetura

- `core/network/paged_response.dart`: wrapper genérico para o envelope
  `Page<T>` do Spring, usado por `/search/products`.
- `features/categories/`: domain + data para categorias.
- `features/products/`: `ProductSummary`, `ProductType`, `ProductRepository`,
  `SearchProductsUseCase`, mapper e `ProductRepositoryImpl`.
- `features/home/presentation/`: `HomeProviders` (Riverpod — filtros de
  categoria/termo de busca, lista paginada), `HomePage`, `ProductSummaryCard`.

## UI

- Busca por texto (`AppSearchField`).
- Chips horizontais de categoria (`AppChip`), múltipla seleção por path.
- Grid 2 colunas de produtos (`GridView.builder` +
  `SliverGridDelegateWithFixedCrossAxisCount`), cada card com imagem, nome,
  loja, preço e badge PRODUTO/SERVIÇO.
- Tap no card navega para `/products/:id` passando o nome da loja via
  `extra`.

## Bug corrigido (2026-08-18)

`ProductSummaryCard` estourava a altura do card em ~25px
(`childAspectRatio: 0.68` deixava pouca altura pro texto quando o nome do
produto ocupava 2 linhas). Corrigido aumentando o aspect ratio dos itens do
grid em [`home_page.dart`](../../lib/features/home/presentation/pages/home_page.dart)
de `0.68` para `0.6`.
