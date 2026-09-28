# happfest_fornecedor

App do fornecedor (HappFest). Consome os endpoints `/suppliers/*`, `/products/*`,
`/sub-orders/*`, `/stores/*` e afins da mesma API do app comprador — ver o
`AGENTS.md` na raiz do monorepo.

Compartilha `happfest_core` (rede, erro, storage, config) e
`happfest_design_system` (tokens, tema, componentes) com `apps/buyer` via
`packages/`.

## Rodando

```
fvm flutter run --flavor dev -t lib/main_dev.dart
```

## Status

Fase 0 (setup) concluída: flavors, lints, CI, dependências e um shell de app
que sobe e mostra uma tela placeholder. As features (login, dashboard,
pedidos, produtos, agenda, documentos) entram uma a uma — ver AGENTS.md
seção 15.
