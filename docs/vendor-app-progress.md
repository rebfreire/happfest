# Progresso — app do fornecedor (apps/vendor)

> Documento de continuidade. Atualizado a cada tela/fase concluída. Se uma
> sessão nova pegar o trabalho, comece lendo isto + `AGENTS.md` (raiz).

**Branch:** `feat/monorepo-vendor-app` · **PR:** https://github.com/rebfreire/happfest/pull/1 (aberto, não mergeado)

## O que já existe

### 1. Monorepo (feito)
Repo `happfest` (antes um único app Flutter) virou monorepo:
```
apps/buyer/    — app do comprador (movido, sem mudança de comportamento)
apps/vendor/   — app do fornecedor (novo)
packages/core/            — happfest_core: dio/DioClient, Failure/Result,
                             TokenStorage, Env/Flavor, providers Riverpod
                             globais (envProvider, tokenStorageProvider,
                             dioProvider) em core/di/app_providers.dart
packages/auth/            — happfest_auth: login/sessão completo (domain +
                             data + LoginController/LoginState). Promovido
                             do buyer porque é 100% idêntico nos dois apps
                             (mesmo /auth/login, mesmo contrato, mesmos 4
                             ProfileType). Só a LoginPage (UI) fica em cada
                             app, por causa do l10n gerado por app.
packages/design_system/   — happfest_design_system: tokens, tema,
                             componentes (AppButton, AppCard, AppScaffold,
                             AppLoading, AppErrorState, AppEmptyState...)
```
Sem Melos — cada `pubspec.yaml` usa `path:` dependency direto. CI
(`.github/workflows/ci.yaml`) roda em matrix nos 5 projetos (3 packages +
2 apps), com `working-directory` por projeto.

### 2. apps/vendor — Fase 0 (feito)
Flavors dev/staging/prod (`br.com.comcode.happfest.fornecedor`), lints
(very_good_analysis), i18n (pt/en, `lib/l10n/`), Firebase (pendente
`flutterfire configure`, mesma pendência do buyer), app shell (Riverpod +
go_router + Material 3).

### 3. Login do fornecedor (feito)
`lib/features/auth/presentation/pages/login_page.dart` — tela própria (UI +
l10n do app), reusa `LoginController`/`LoginState`/`LoginUseCase` de
`happfest_auth`. Rota inicial `/login`; sucesso → `/`.

### 4. Dashboard (feito)
`lib/features/dashboard/` — Clean Architecture completa:
- `domain/entities`: `SupplierProfile`, `SupplierMetrics`, `SubOrderPreview`
  (preview simplificado — a feature `orders`, feita mais adiante, terá a
  entidade completa de sub-pedido; **não reusar/inflar este preview**,
  criar o modelo certo lá).
- `domain/repositories` + `usecases` (um usecase por ação, padrão do
  projeto): `GetSupplierProfileUseCase`, `GetSupplierMetricsUseCase`,
  `GetPendingOrdersUseCase`.
- `data`: DTOs de `/suppliers/me`, `/suppliers/me/metrics`,
  `/sub-orders?status=PENDING` (subset de campos, só o que a tela usa).
- `presentation`: `DashboardPage` com 3 `FutureProvider<Result<T>>`
  independentes (perfil, métricas, pedidos pendentes), cada um com seu
  próprio loading/erro/vazio — mesmo padrão do `HomePage` do buyer.

Testes: 3 unit (usecases, mock do repositório) + 3 widget (`DashboardPage`
em sucesso/vazio/erro). Tudo verde (`flutter analyze` e `flutter test`).

## Achados / armadilhas (não repetir)

1. **`AppLoading.skeleton()` é um `ListView` internamente.** Nunca usar
   dentro de outro `ListView`/`Column` que já está dentro de um scroll —
   quebra com "Vertical viewport was given unbounded height." Usar
   `AppLoading()` (spinner simples) pra loading inline dentro de seção de
   página; `.skeleton()` só quando o widget *é* o body inteiro da tela.
2. **Teste de widget que verifica `l10n.appName` por texto quebra se
   pt/en tiverem valores diferentes** — o ambiente de teste usa locale
   `en` por padrão. Ou fixar `locale: Locale('pt')` no `MaterialApp` do
   teste, ou manter o mesmo valor nos dois ARBs (foi o que fizemos:
   `appName` = "HappFest Fornecedor" em pt **e** en).
3. **`flutter create` gera o pacote Kotlin do `MainActivity.kt` com
   underscore** (`happfest_fornecedor`) mesmo quando o `namespace`/
   `applicationId` usa ponto (`happfest.fornecedor`). Já corrigido — se
   criar outro app do zero, checar isso (`android/app/.../MainActivity.kt`
   tem que estar no mesmo pacote do `namespace` do `build.gradle.kts`).
4. **`.gitignore` de `build/`** precisa ser `**/build/` (não `/build/`) em
   monorepo — senão só ignora na raiz e o `flutter analyze` varre lixo de
   `build/ios/SourcePackages/...` de cada app.
5. **flutter/dart não estão no PATH direto**, só via `fvm flutter` / `fvm
   dart` (ambiente sem Android SDK completo / Xcode completo — mesma
   pendência documentada no `AGENTS.md` seção 0.1 do buyer). Rodar tudo
   com `fvm`.
6. `ambiente Bash` às vezes falha transitoriamente no classificador de
   auto-mode; só retry, não é o comando que está errado.

## Endpoints já mapeados por feature futura (do `docs/api/openapi.json`)

- **orders** (próxima): `GET /sub-orders` (lista, filtro status/data),
  `GET /sub-orders/{id}`, `POST /sub-orders/{id}/accept|reject|deliver|
  complete|cancel/supplier|contest`, chat: `GET/POST
  /chats/sub-orders/{id}/messages`.
- **products**: `GET/POST /products/stores/{storeId}`, `GET/PUT/DELETE
  /products/{id}`, `/products/{id}/status|featured`, variantes
  (`/products/{productId}/variants*`, bulk-price, bulk-stock, generate),
  imagens (`/products/{productId}/images`, cover), promoções, perguntas,
  reviews, `operating-days`, `service-config`.
- **agenda**: `GET /supplier/agenda` (paginado, from/to, status
  RESERVED/BLOCKED).
- **documentos**: `GET/POST /suppliers/{id}/documents`, download, delete.
- **perfil/métricas**: `GET /suppliers/me`, `/suppliers/me/metrics`
  (já usado no dashboard), `/suppliers/me/questions`,
  `/suppliers/me/product-reviews`, `/ledger/me`, `/balances/me`.
- **notificações**: `GET /notifications/me`, `/unread`, `/unread-count`,
  `POST /notifications/{id}/read`, `/read-all`.

## Sequência combinada com o usuário (ordem de implementação)

1. ~~Login~~ ✅
2. ~~Dashboard~~ ✅
3. **Pedidos (orders)** ← próximo: lista + aceitar/recusar/entregar/
   concluir/cancelar sub-pedido
4. Produtos (catálogo, CRUD, variantes, fotos)
5. Agenda
6. Documentos
7. Perfil / métricas (tela dedicada, hoje só aparece resumida no
   dashboard)
8. Chat (por sub-pedido)
9. Notificações

Cada item = 1 commit (ou mais) na mesma branch/PR, seguindo
`domain → data → presentation → teste` (AGENTS.md seção 14-15). Rodar
sempre `fvm flutter analyze` + `fvm flutter test` limpos antes de
considerar pronto.
