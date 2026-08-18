# Fase 0 — Setup

Status: ✅ Concluída · Commit: `54a29de`

## O que foi feito

- Projeto Flutter criado em `~/Developer/happfest` (fora do Google Drive),
  ligado ao repo `github.com/rebfreire/happfest`.
- FVM travado em Flutter 3.44.x / Dart 3.12 (`.fvmrc` commitado).
- 3 flavors (dev/staging/prod) — todos apontando para
  `https://happ-api.comcode.com.br/api/v1` até existirem ambientes separados.
- Estrutura de pastas feature-first: `app/`, `core/`, `design_system/`,
  `features/`, `l10n/`.
- Dependências: `flutter_riverpod`, `go_router`, `dio`, `freezed` +
  `json_serializable`, `flutter_secure_storage`, `flutter_localizations` +
  ARB, `very_good_analysis`, `firebase_core/analytics/crashlytics`.
- `AGENTS.md` na raiz — cópia do guia técnico com a Seção 0 preenchida
  (nome do app, bundle id, URL da API, tipo de auth, analytics).
- CI básico no GitHub Actions (`flutter analyze` → `dart format --check` →
  `flutter test`).
- Logo (`happ-logo.svg`) baixado do site como base do ícone do app.

## Decisão arquitetural relevante

`riverpod_generator` (codegen `@riverpod`) entrou em conflito de versão do
`analyzer` com `freezed`/`json_serializable` no grafo de dependências. Decisão:
abandonar o codegen do Riverpod e usar `Notifier`/`NotifierProvider`/
`FutureProvider`/`FutureProvider.family` manuais. Trade-off aceito
conscientemente — não é um desvio acidental do guia.

## Pendências

- Flavors (dev/staging/prod) ainda não têm schemes separados no Xcode.
- `flutterfire configure` não rodado — Firebase integrado defensivamente no
  código mas sem projeto real.
