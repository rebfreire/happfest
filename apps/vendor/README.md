# happfest_fornecedor

App do fornecedor (HappFest). Consome os endpoints `/suppliers/*`, `/products/*`,
`/sub-orders/*`, `/stores/*` e afins da mesma API do app comprador — ver o
`AGENTS.md` na raiz do monorepo.

Compartilha `happfest_core` (rede, erro, storage, config, DI),
`happfest_auth` (login/sessão) e `happfest_design_system` (tokens, tema,
componentes) com `apps/buyer` via `packages/`.

## Rodando

```
fvm flutter run --flavor dev -t lib/main_dev.dart
```

## Status

Fase 0 (setup) e login concluídos: flavors, lints, CI, dependências, tela de
login (reusando `happfest_auth`) e um shell de app que sobe e, após
autenticar, mostra uma tela placeholder. As demais features (dashboard,
pedidos, produtos, agenda, documentos) entram uma a uma — ver AGENTS.md
seção 15.
