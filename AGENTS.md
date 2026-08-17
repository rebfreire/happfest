# Guia Técnico — Aplicativo Flutter (iOS + Android)

> **Para quem é este documento:** desenvolvedor que vai construir o app consumindo as nossas APIs, usando IA (Claude Code, Cursor, Codex etc.) como par de programação.
>
> **Como usar:** copie este arquivo para a raiz do projeto como `AGENTS.md` (ou `.cursor/rules/projeto.mdc` / `CLAUDE.md`). Toda sessão de IA deve começar lendo este arquivo. Ele é a **fonte única de verdade** de arquitetura, padrões e critérios de aceite.
>
> **Regra de ouro:** se a IA propuser algo que contraria este documento, o documento vence. Se o documento estiver errado, **atualize o documento primeiro**, depois o código.

---

## 0. Preencher antes de começar

Esta seção é o único ponto do documento que precisa ser completado com dados do projeto.

| Item | Valor |
|---|---|
| Nome do app | HappFest (comprador) — provisório, ajustar se necessário |
| Bundle ID iOS / applicationId Android | `br.com.comcode.happfest` (prod) / `.dev` / `.staging` para os outros flavors |
| Base URL (dev / staging / prod) | `https://happ-api.comcode.com.br/api/v1` nos 3 flavors por enquanto — não há dev/staging separados ainda |
| Documentação da API (OpenAPI/Swagger) | https://happ-api.comcode.com.br/api/v1/swagger-ui/index.html · JSON: https://happ-api.comcode.com.br/api/v1/api-docs |
| Tipo de autenticação | JWT Bearer. `POST /auth/login` (email/senha) retorna `{ token, userId, profileType, permissions }`. `POST /auth/refresh?token=...` troca o token atual por um novo — **não há refresh token separado** no contrato atual. Login Google (`/auth/google`) existe na API mas fica fora da v1 do app. |
| Versões mínimas suportadas | iOS 15+ / Android 8 (API 26)+ |
| Idiomas | pt-BR (padrão) + en |
| Analytics / Crash | Firebase (Analytics + Crashlytics) — SDKs já no `pubspec.yaml`; falta rodar `flutterfire configure` (login interativo, fora do escopo desta sessão) |

**Escopo deste repositório:** app do **comprador** (busca, produto, carrinho, checkout, pedidos, conta). As áreas de fornecedor, franquia e admin do backend (`/suppliers/*`, `/franchise/*`, `/admin/*`) ficam fora — serão um app Flutter separado, discutido depois.

**Importante:** o `api-docs` (OpenAPI) já foi baixado e é a fonte de verdade dos models — a IA deve gerar os models e o client **a partir do contrato**, nunca "adivinhando" campos.

### 0.1 Pendências manuais (fora do alcance de automação nesta sessão)

- **Xcode incompleto**: só o Command Line Tools está instalado. Para rodar/buildar iOS: instalar o Xcode completo pela App Store, depois `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` e `sudo xcodebuild -runFirstLaunch`, e instalar o CocoaPods (`sudo gem install cocoapods` ou `brew install cocoapods`).
- **Android SDK ausente**: instalar o Android Studio (ele guia a instalação do SDK) e rodar `flutter doctor --android-licenses`.
- **Schemes do Xcode para os flavors**: os arquivos `ios/Flutter/Flavors/{Dev,Staging,Prod}.xcconfig` já existem, mas as **Build Configurations e Schemes correspondentes no Xcode** (Debug-dev/Release-dev, etc.) precisam ser criadas manualmente abrindo `ios/Runner.xcworkspace` no Xcode — editar o `project.pbxproj` às cegas sem o Xcode para validar é arriscado demais.
- **Firebase**: rodar `flutterfire configure` (requer login na conta Google/Firebase do projeto) para gerar `firebase_options.dart` e os arquivos nativos (`google-services.json` / `GoogleService-Info.plist`).
- **Assinatura de release**: builds de release ainda assinam com a debug key (ver `android/app/build.gradle.kts`) — configurar keystore antes de publicar.

---

## 1. Stack obrigatória

Versões de referência (mercado em ago/2026 — trave no `pubspec.yaml` e só suba com PR dedicado):

| Camada | Escolha | Observação |
|---|---|---|
| SDK | **Flutter 3.44.x / Dart 3.12** | canal `stable`, fixado via FVM |
| Design | **Material 3** (`useMaterial3: true`) | adaptativo para iOS onde fizer sentido |
| Estado | **Riverpod 3** (`flutter_riverpod` + `riverpod_annotation`) | uma única solução de estado no app inteiro |
| Navegação | **go_router** (rotas tipadas com `go_router_builder`) | deep links + rotas nomeadas |
| DI | Riverpod como container de DI (dispensa `get_it` na maioria dos casos) | se usar `get_it`, use `injectable` |
| HTTP | **dio** + interceptors | nunca `http` puro espalhado |
| Modelos | **freezed** + `json_serializable` | imutáveis, `copyWith`, união selada |
| Persistência local | **drift** (relacional) ou **isar/hive** (chave-valor) | escolher **uma** |
| Segredos locais | `flutter_secure_storage` | tokens **nunca** em SharedPreferences |
| i18n | `flutter_localizations` + ARB (`gen-l10n`) | zero string hardcoded na UI |
| Testes | `flutter_test`, `mocktail`, `golden_toolkit`/`alchemist`, `patrol` ou `integration_test` | |
| Lints | `very_good_analysis` (ou `flutter_lints` + regras extras) | CI quebra em warning |
| Versionamento SDK | **FVM** (`.fvmrc` commitado) | todo mundo na mesma versão |

**Proibido sem discussão prévia:** misturar Bloc + Riverpod, usar `GetX`, usar `setState` para estado de negócio, usar pacotes sem manutenção há mais de 12 meses.

---

## 2. Arquitetura

**Clean Architecture + organização feature-first.** Três camadas por feature:

```
presentation  →  widgets, telas, controllers (Riverpod Notifier)
    ↓ depende de
domain        →  entities, repositories (interfaces), use cases  [Dart puro, ZERO import de Flutter]
    ↑ implementa
data          →  DTOs, datasources (remoto/local), implementação dos repositories
```

Regras não negociáveis:

1. `domain/` não importa `package:flutter/*`, `dio`, `drift`, nem nada de infra. Se compilar como pacote Dart puro, está certo.
2. A UI **nunca** chama `dio` ou datasource direto. Sempre: Widget → Controller (Notifier) → UseCase → Repository (interface) → DataSource.
3. Toda operação que pode falhar retorna `Result<Failure, T>` — não se joga exceção atravessando camadas.
4. Widget não contém regra de negócio. Widget lê estado e dispara intenções.
5. DTO (data) ≠ Entity (domain). Sempre há um `mapper`.

### 2.1 Estrutura de pastas

```
lib/
├── main.dart
├── bootstrap.dart                 # runZonedGuarded, error handlers, ProviderScope
├── app/
│   ├── app.dart                   # MaterialApp.router
│   ├── router/                    # go_router, rotas, guards, transições
│   └── di/                        # providers globais (dio, storage, env)
├── core/
│   ├── config/                    # Env (dart-define), flavors, constantes
│   ├── network/                   # DioClient, interceptors, ApiException
│   ├── error/                     # Failure, Result, mapeamento de erros
│   ├── storage/                   # secure storage, cache
│   ├── utils/                     # extensions, formatters (data, moeda, doc)
│   └── logging/
├── design_system/                 # ⚠️ ver seção 3 — o coração da padronização
│   ├── tokens/                    # cores, espaçamento, raio, sombra, tipografia, duração
│   ├── theme/                     # AppTheme light/dark, ThemeExtensions
│   ├── components/                # AppButton, AppTextField, AppCard, AppDialog...
│   ├── feedback/                  # snackbars, toasts, loading overlay, empty/error states
│   └── layout/                    # responsividade, breakpoints, AppScaffold, grids
├── features/
│   └── <feature>/
│       ├── domain/    (entities, repositories, usecases)
│       ├── data/      (dtos, datasources, repositories_impl, mappers)
│       └── presentation/ (pages, widgets, controllers, state)
└── l10n/                          # arb + gerados
test/
├── unit/  widget/  golden/
integration_test/
```

Uma feature nunca importa `presentation/` de outra feature. Compartilhamento acontece via `core/` ou `design_system/`.

---

## 3. Design System — padronização total (requisito central)

**Objetivo:** trocar a cor primária, o raio da borda ou o padding em **um único arquivo** e o app inteiro mudar. Nenhum valor "mágico" espalhado pelo código.

### 3.1 Tokens

```dart
// design_system/tokens/app_colors.dart
abstract final class AppColors {
  static const primary       = Color(0xFF1B5E20);
  static const onPrimary     = Color(0xFFFFFFFF);
  static const secondary     = Color(0xFF00796B);
  static const danger        = Color(0xFFC62828); // excluir/destrutivo
  static const success       = Color(0xFF2E7D32);
  static const warning       = Color(0xFFEF6C00);
  static const surface       = Color(0xFFFFFFFF);
  static const outline       = Color(0xFFDADDE1);
  static const textPrimary   = Color(0xFF1A1C1E);
  static const textSecondary = Color(0xFF5F6368);
}

// design_system/tokens/app_spacing.dart  (escala de 4)
abstract final class AppSpacing {
  static const xxs = 2.0;  static const xs = 4.0;   static const sm = 8.0;
  static const md  = 16.0; static const lg = 24.0;  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadius {
  static const sm = 8.0; static const md = 12.0; static const lg = 20.0; static const pill = 999.0;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
}
```

**Proibido na UI:** `Color(0xFF...)`, `EdgeInsets.all(13)`, `BorderRadius.circular(7)`, `TextStyle(fontSize: 15)`. Sempre token ou `Theme.of(context)`.

Se precisar de um valor que não existe no token, **adicione ao token** — não improvise local.

### 3.2 Tema e ThemeExtension

Todo o tema vive em `design_system/theme/app_theme.dart`: `ColorScheme` gerado dos tokens, `TextTheme`, e os `*ThemeData` dos componentes do Material (`elevatedButtonTheme`, `inputDecorationTheme`, `cardTheme`, `appBarTheme`, `dialogTheme`, `snackBarTheme`...).

Cores/medidas que não existem no Material (ex.: `success`, `warning`, `brandGradient`) entram via `ThemeExtension`:

```dart
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success, warning, danger, info;
  const AppSemanticColors({required this.success, required this.warning,
                           required this.danger, required this.info});
  @override AppSemanticColors copyWith({Color? success, Color? warning, Color? danger, Color? info}) => ...
  @override AppSemanticColors lerp(covariant ThemeExtension<AppSemanticColors>? other, double t) => ...
}
// uso: Theme.of(context).extension<AppSemanticColors>()!.success
```

Dark mode é **obrigatório desde o dia 1** (`themeMode: ThemeMode.system` + tema escuro completo). Adaptar depois custa 10x.

### 3.3 Componentes obrigatórios (a UI só usa estes)

Um único `AppButton` com variantes — **não** se cria botão novo por tela:

```dart
enum AppButtonVariant { primary, secondary, tertiary, danger, ghost }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,          // null = disabled (semântica explícita)
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });
  // Construtores semânticos — usados no app inteiro:
  factory AppButton.save({...})    => variant: primary
  factory AppButton.cancel({...})  => variant: ghost
  factory AppButton.delete({...})  => variant: danger
  factory AppButton.confirm({...}) => variant: primary
}
```

Regras do botão: altura mínima de toque **48dp**; `isLoading` desabilita e mostra spinner (previne duplo submit); label vem do `l10n`; nunca `TextButton`/`ElevatedButton` cru na feature.

Catálogo mínimo a construir **antes** das telas:

| Componente | Cobre |
|---|---|
| `AppButton` | primary, secondary, danger (excluir), ghost (cancelar), loading, ícone |
| `AppTextField` | label, hint, erro, senha, máscara (CPF/CNPJ/telefone/moeda/data), contador |
| `AppDropdown` / `AppSearchField` / `AppCheckbox` / `AppSwitch` / `AppRadioGroup` | |
| `AppScaffold` | AppBar padrão, SafeArea, gestão de teclado, pull-to-refresh, FAB |
| `AppCard`, `AppListTile`, `AppChip`, `AppBadge`, `AppAvatar` | |
| `AppDialog` | `.confirm()`, `.destructive()`, `.info()` — botões já padronizados |
| `AppBottomSheet` | |
| `AppSnackbar` | `.success()`, `.error()`, `.warning()`, `.info()` |
| `AppLoading` | inline, overlay, **skeleton/shimmer** para listas |
| `AppEmptyState` / `AppErrorState` | ícone + mensagem + ação de retry |
| `AppPagedListView` | paginação infinita + loading + erro + vazio |
| `AppFormLayout` | espaçamento vertical consistente entre campos |

### 3.4 Estados de tela — os 4 estados sempre

Toda tela que carrega dados trata **loading / vazio / erro / conteúdo**. Nada de tela branca ou spinner infinito. Padronizar via um widget:

```dart
AsyncValueWidget<T>(
  value: ref.watch(algumProvider),
  data:    (d) => Conteudo(d),
  loading: () => const AppLoading.skeleton(),
  error:   (e, _) => AppErrorState(failure: e, onRetry: () => ref.invalidate(algumProvider)),
  empty:   () => const AppEmptyState(...),
)
```

### 3.5 Storybook interno

Criar uma rota `/dev/design-system` (só em debug) listando todos os componentes em todas as variantes/estados. Serve de vitrine, de teste manual e de referência para a IA. Vale muito o esforço.

---

## 4. Responsividade e compatibilidade (não quebrar em nenhum celular)

Requisito explícito: **funcionar em todos os aparelhos**. Regras:

1. **Nunca** usar valores absolutos de tela nem `MediaQuery.of(context).size.width * 0.37` como layout. Usar `Expanded`, `Flexible`, `LayoutBuilder`, `FractionallySizedBox`, `Wrap`.
2. **Nunca** ignorar overflow. Todo texto que pode crescer usa `maxLines` + `TextOverflow.ellipsis` ou `Flexible`.
3. Conteúdo de tela dentro de `SingleChildScrollView`/`CustomScrollView` quando o teclado puder cobrir campos (`resizeToAvoidBottomInset`).
4. `SafeArea` sempre — notch, Dynamic Island, barra de gestos.
5. **Text scaling:** o app deve funcionar com fonte do sistema em 200%. Testar. Nunca fixar altura de widget que contém texto.
6. Breakpoints padronizados: `compact < 600 ≤ medium < 840 ≤ expanded` (tablet/foldable → NavigationRail em vez de BottomBar).
7. Orientação: definir por tela; se travar em `portrait`, travar explicitamente.
8. Densidades: testar em telas pequenas (Moto E, ~5", 360x640 @ dpr 2) e grandes (iPhone Pro Max, tablets).
9. Imagens sempre com `cached_network_image`, `errorWidget` e `placeholder`.
10. Listas sempre `ListView.builder`/`SliverList` — nunca `Column` dentro de `SingleChildScrollView` com N itens do backend.

**Matriz mínima de testes manuais antes de cada release:**
Android 8 (360x640), Android 14 (1080x2400), iPhone SE (small), iPhone 15 Pro (notch), tablet 10", modo escuro, fonte 200%, sem internet, internet lenta (3G).

---

## 5. Camada de rede

```dart
// core/network/dio_client.dart
Dio buildDio(Env env, TokenStorage storage) => Dio(BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ))
  ..interceptors.addAll([
    AuthInterceptor(storage),      // injeta Bearer, faz refresh no 401 (com fila para evitar N refreshes)
    RetryInterceptor(),            // retry com backoff só em erro de rede / 5xx / métodos idempotentes
    ErrorMapperInterceptor(),      // DioException -> Failure tipado
    if (env.isDebug) PrettyLogInterceptor(), // NUNCA logar token/senha
  ]);
```

Regras:

- Timeouts sempre definidos. Sem timeout = tela travada.
- `CancelToken` em buscas/telas que podem ser fechadas antes da resposta.
- Mapeamento de erro obrigatório: `NetworkFailure`, `UnauthorizedFailure`, `ForbiddenFailure`, `NotFoundFailure`, `ValidationFailure(campos)`, `ServerFailure`, `UnknownFailure`. A UI decide a mensagem a partir do tipo — nunca mostra `Exception: ...` cru pro usuário.
- Paginação: padronizar um `PagedResponse<T>` conforme o contrato da API.
- Refresh token com fila (mutex) para não disparar múltiplos refresh simultâneos.
- Toda chamada de API tem teste unitário com mock de resposta (sucesso + 4xx + 5xx + timeout).

### 5.1 Result

```dart
sealed class Result<T> { const Result(); }
final class Ok<T>  extends Result<T> { final T value;      const Ok(this.value); }
final class Err<T> extends Result<T> { final Failure error; const Err(this.error); }
```

---

## 6. Estado (Riverpod)

- Um `Notifier`/`AsyncNotifier` por tela ou por caso de uso — nada de "provider deus".
- Usar `@riverpod` (codegen) para type-safety.
- Estado da tela é uma classe `freezed` imutável (`Loading | Data | Error` ou campos explícitos).
- `ref.watch` para reagir, `ref.read` só dentro de callbacks.
- Nada de `BuildContext` dentro de Notifier.
- Efeitos colaterais (snackbar, navegação) ficam na camada de UI, ouvindo o estado com `ref.listen`.

---

## 7. Navegação

- `go_router` com rotas declaradas em um único arquivo + rotas tipadas (`go_router_builder`).
- `ShellRoute` para bottom navigation com estado preservado (`StatefulShellRoute.indexedStack`).
- `redirect` central para autenticação (não logado → `/login`; logado em `/login` → `/home`).
- Deep links configurados em iOS (Associated Domains) e Android (App Links) desde o início.
- Nada de `Navigator.push(MaterialPageRoute(...))` espalhado.
- Botão físico de voltar (Android) tratado com `PopScope` em formulários com alterações não salvas ("Descartar alterações?").

---

## 8. Offline, cache e sincronização

- Definir por tela: precisa funcionar offline? (listar dados em cache, bloquear ações de escrita, banner "sem conexão").
- `connectivity_plus` para estado de rede + banner global.
- Cache de leitura com TTL no repositório (stale-while-revalidate: mostra cache, atualiza em background).
- Fila de operações pendentes só se o requisito exigir — não implementar por antecipação.

---

## 9. Segurança

- Tokens/credenciais só em `flutter_secure_storage` (Keychain / EncryptedSharedPreferences).
- Nenhum segredo no repositório. Configuração via `--dart-define` / `--dart-define-from-file` e secrets do CI.
- HTTPS obrigatório; `usesCleartextTraffic=false`.
- Logs sem PII e desligados em release.
- Ofuscação em release: `flutter build --obfuscate --split-debug-info=build/symbols`.
- Validação de entrada no cliente **e** confiança zero: a API é a autoridade.
- LGPD: tela de política de privacidade, consentimento e caminho para exclusão de conta (exigido pela Apple/Google).
- Permissões (câmera, localização, notificação) pedidas **no momento do uso**, com texto justificando, e com fallback caso negada.

---

## 10. Internacionalização e acessibilidade

- 100% das strings em ARB (`app_pt.arb`, `app_en.arb`). Zero string literal em widget.
- Datas, números, moeda via `intl` com locale — nunca concatenação manual.
- Acessibilidade: `Semantics`/`semanticLabel` em ícones e botões só-ícone; contraste mínimo 4.5:1; alvo de toque ≥ 48dp; navegação por leitor de tela testada em pelo menos os fluxos principais; nunca transmitir informação só por cor.

---

## 11. Testes

| Tipo | Cobertura esperada | O quê |
|---|---|---|
| Unit | ≥ 80% em `domain/` e `data/` | usecases, mappers, repositories (com mock de datasource), validators |
| Widget | telas principais | estados loading/erro/vazio/conteúdo, interações |
| Golden | todos os componentes do design system | evita regressão visual ao mexer no tema |
| Integração (E2E) | fluxos críticos | login, cadastro, fluxo principal, logout |

- `mocktail` para mocks; sem chamada real de rede em teste.
- Teste é parte do PR, não tarefa futura. **PR sem teste do que mudou não entra.**

---

## 12. Qualidade, CI/CD e processo

- `analysis_options.yaml` com `very_good_analysis`; warnings tratados como erro no CI.
- **Conventional Commits** (`feat:`, `fix:`, `refactor:`, `test:`, `chore:`) — habilita changelog automático.
- Branches: `main` (produção) / `develop` / `feature/*` / `hotfix/*`. PR obrigatório, sem push direto.
- Flavors: `dev`, `staging`, `prod` — com nome, ícone e bundle id distintos (dá pra ter os três instalados no mesmo celular).
- Pipeline (GitHub Actions / Codemagic):
  1. `flutter analyze` → 2. `dart format --set-exit-if-changed` → 3. `flutter test --coverage` → 4. build Android (AAB) + iOS → 5. distribuição (Firebase App Distribution / TestFlight).
- Crash reporting + analytics desde a primeira build interna.
- Versionamento: `major.minor.patch+build`, build incrementado pelo CI.

---

## 13. Performance

- `const` em tudo que for possível (o lint cobra).
- `ListView.builder` + `itemExtent`/`prototypeItem` quando a altura for fixa.
- Evitar rebuild de árvore inteira: providers granulares, `select`, extrair widgets.
- Imagens redimensionadas no servidor; `cacheWidth`/`cacheHeight` no cliente.
- Nada de trabalho pesado na `build()`; JSON grande → `compute()`/isolate.
- Meta: startup < 2s, scroll sem jank (verificar no DevTools com **profile mode**, nunca em debug).
- Tamanho do app monitorado a cada release (`--analyze-size`).

---

## 14. Regras para o agente de IA

Cole isto junto com o resto quando abrir a sessão:

**Sempre:**
1. Antes de escrever código, listar os arquivos que vai criar/alterar e esperar confirmação.
2. Seguir a estrutura de pastas da seção 2.1 exatamente.
3. Reusar componentes existentes de `design_system/`. Se faltar um, criar **lá** (genérico e reutilizável), não dentro da feature.
4. Usar tokens — nunca cor, espaçamento, raio ou fonte hardcoded.
5. Toda string de UI vai para o ARB.
6. Toda chamada de API retorna `Result` e trata os 4 estados na tela.
7. Entregar o teste junto com o código.
8. Rodar `flutter analyze` e `flutter test` e corrigir tudo antes de dizer "pronto".

**Nunca:**
1. Alterar arquivo fora do escopo da tarefa pedida.
2. Criar um segundo padrão para algo que já existe (segundo botão, segundo cliente HTTP, segundo gerenciador de estado).
3. Adicionar dependência nova sem justificar (manutenção ativa, licença, tamanho, alternativa nativa).
4. Deixar `TODO`, `print()`, código comentado ou dado mockado em código de produção.
5. "Consertar" erro de compilação removendo funcionalidade ou colocando `try/catch` vazio.
6. Usar `!` (bang) sem checagem, ou `dynamic` fora de fronteira de serialização.
7. Refatorar em massa junto com feature nova — refactor é PR separado.

**Escopo por tarefa:** uma feature por vez, seguindo sempre a ordem `domain → data → presentation → teste`. Não gerar o app inteiro em uma tacada: gera dívida técnica invisível e impossível de revisar.

---

## 15. Ordem de execução sugerida

| Fase | Entrega | Critério de pronto |
|---|---|---|
| 0 | Setup: FVM, flavors, lints, CI, estrutura de pastas, `.env`/dart-define | `flutter run` nos 3 flavors, pipeline verde |
| 1 | **Design system + tokens + tema + storybook** | todos os componentes da 3.3 com golden test |
| 2 | Core: dio, interceptors, Result/Failure, storage, router, l10n | testes do client passando |
| 3 | Autenticação: login, refresh, logout, guard de rota, "esqueci a senha" | E2E de login passando |
| 4 | Shell do app: navegação, menus, perfil, tema claro/escuro | funciona em small/large + fonte 200% |
| 5..n | Uma feature por vez, cada uma com CRUD completo e 4 estados | teste + revisão + build interna distribuída |
| Final | Hardening: acessibilidade, performance, offline, LGPD, ícones/splash, store listing | checklist da seção 16 |

**A fase 1 vem antes de qualquer tela.** É ela que garante o requisito de "muda em um lugar, muda em todo lugar".

---

## 16. Definition of Done (checklist de PR)

- [ ] `flutter analyze` sem warning e `dart format` aplicado
- [ ] Testes novos passando; suíte inteira verde
- [ ] Zero string hardcoded (tudo no ARB) e zero valor mágico (tudo em token)
- [ ] Componentes reutilizados do design system; nenhum widget duplicado
- [ ] 4 estados tratados (loading, vazio, erro com retry, conteúdo)
- [ ] Testado em tela pequena, tela grande, modo escuro, fonte 200%, sem internet
- [ ] Sem overflow em nenhum dos cenários acima
- [ ] Acessibilidade: labels semânticos, alvo de toque ≥ 48dp, contraste ok
- [ ] Nenhum segredo, `print()`, `TODO` ou mock em produção
- [ ] Commit em Conventional Commits e PR descrevendo o "porquê"

---

## 17. Prompt inicial para a IA

```
Você vai desenvolver um app Flutter (iOS + Android) seguindo ESTRITAMENTE o
arquivo AGENTS.md na raiz do projeto e o contrato em /docs/api/openapi.yaml.

Contexto: Flutter 3.44 / Dart 3.12, Material 3, Riverpod 3, go_router, dio,
freezed, Clean Architecture feature-first.

Tarefa atual: <descrever UMA feature ou fase>

Antes de codar:
1. Liste os arquivos que pretende criar/alterar, por camada (domain, data, presentation).
2. Aponte qualquer conflito entre a tarefa e o AGENTS.md.
3. Aguarde meu OK.

Depois de codar:
4. Rode flutter analyze e flutter test, corrija tudo.
5. Preencha o checklist da seção 16 do AGENTS.md, item a item, com evidência.

Não altere nada fora do escopo. Não crie padrão novo para algo que já existe.
```

---

## 18. Referências

- Flutter — Architecture guide & samples: https://docs.flutter.dev/app-architecture
- Material 3 (design tokens e componentes): https://m3.material.io
- Riverpod: https://riverpod.dev
- go_router: https://pub.dev/packages/go_router
- Flutter accessibility: https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
- Performance best practices: https://docs.flutter.dev/perf/best-practices
