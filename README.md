# happfest (monorepo)

Monorepo dos apps Flutter do HappFest, consumindo a mesma API
(`https://happ-api.comcode.com.br/api/v1`).

```
apps/
  buyer/    # app do comprador (busca, produto, carrinho, checkout, pedidos, conta)
  vendor/   # app do fornecedor (pedidos, produtos, agenda, documentos, métricas)
packages/
  core/            # happfest_core — rede (dio), erro, storage, config/flavors
  design_system/   # happfest_design_system — tokens, tema, componentes
docs/
  api/openapi.json # contrato da API (fonte de verdade dos models)
  design/          # referências visuais
```

Cada app em `apps/*` é um projeto Flutter independente (`pubspec.yaml`
próprio) que depende de `packages/core` e `packages/design_system` via
path dependency — não há build tool de workspace (Melos) por enquanto,
cada `pubspec.yaml` resolve isso sozinho.

Veja o `AGENTS.md` (regras de arquitetura, stack e padrões, válidas para
todo o monorepo) e o `README.md` de cada app.

## Rodando um app

```
cd apps/buyer   # ou apps/vendor
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter run --flavor dev -t lib/main_dev.dart
```
