# Categorias

Status: ✅ Concluído

## Arquitetura

- `CategoryRepository.getChildren(path)` (`GET /categories/path/{path}/children`)
  soma-se ao `getRootCategories()` já existente.
- [`CategoriesPage`](../../lib/features/categories/presentation/pages/categories_page.dart):
  navegação em árvore — raiz → subcategorias, com breadcrumb tocável no
  topo. Tocar numa categoria com filhas (`hasChildren`) desce um nível; numa
  categoria folha, navega para a lista de produtos daquela categoria.
- [`CategoryProductsPage`](../../lib/features/categories/presentation/pages/category_products_page.dart)
  (rota `/categorias/produtos/:path`): reusa `SearchProductsUseCase`
  filtrado por `categoryPath`.
- [`ProductResultsGrid`](../../lib/features/products/presentation/widgets/product_results_grid.dart):
  grid de produtos com estados de loading/erro/vazio extraído da `HomePage`
  para ser compartilhado entre Home e Categorias (evita duplicar a lógica).

## Endpoints usados

`GET /categories`, `GET /categories/path/{path}/children`,
`GET /search/products?categoryPath=...`.
