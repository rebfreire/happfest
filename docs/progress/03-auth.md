# Autenticação (Login)

Status: ✅ App corrigido · ⚠️ Bloqueado por bug no backend (ver abaixo) ·
Commit: `b9e4ce0` (implementação inicial)

## Escopo

Login apenas por email/senha (`POST /auth/login`) na v1. Login social
(Google, `/auth/google`) fica para depois.

## Arquitetura

- `domain/`: `AuthSession`, `ProfileType`, `AuthRepository` (interface),
  `LoginUseCase`.
- `data/`: `LoginRequestDto`/`LoginResponseDto`, `AuthRemoteDatasource`
  (dio), `AuthSessionMapper`, `AuthRepositoryImpl`.
- `presentation/`: `LoginController` (`Notifier<LoginState>` — estados
  `idle`/`loading`/`success`/`failure`), `LoginPage`.
- Token: `TokenStorage` (`flutter_secure_storage`) guarda um único token
  (a API não usa par access+refresh separado).
- `AuthInterceptor` (dio) injeta o Bearer e faz refresh single-flight via
  `POST /auth/refresh?token=...` quando necessário.

## Diagnóstico (2026-08-18)

Login com credenciais reais deixava a tela travada em loading para sempre,
sem erro nenhum aparecer. Root cause encontrado instrumentando o app com
`log stream` do simulador (o `flutter run` estava perdendo a conexão de
debug repetidamente, então os logs normais via `dart:developer` não
apareciam):

- A API responde `200 OK` no login bem-sucedido, mas com **`"token": null`**
  no corpo (confirmado via `curl` direto, fora do app: `{"token":null,
  "userId":"...","profileType":"CUSTOMER","permissions":[]}`).
- `LoginResponseDto.token` era tipado como `String` obrigatório
  (não-nullable). O `json_serializable` gerado lança uma exceção ao tentar
  fazer parse de `null` nesse campo — uma exceção que **não é
  `DioException`**, então o `catch (DioException)` em `AuthRepositoryImpl`
  não pegava. A exceção subia sem tratamento, o `state = switch(...)` do
  `LoginController.submit()` nunca era alcançado, e o `state` ficava preso
  em `LoginState.loading()` para sempre — daí o "travamento" sem log de
  erro.

**Corrigido no app** ([`login_response_dto.dart`](../../lib/features/auth/data/dto/login_response_dto.dart),
[`auth_repository_impl.dart`](../../lib/features/auth/data/repositories/auth_repository_impl.dart)):
`token` agora é nullable no DTO; quando vem `null`, `AuthRepositoryImpl`
retorna `Err(UnknownFailure(...))` com mensagem clara em vez de travar.
Teste de regressão em
[`auth_repository_impl_test.dart`](../../test/unit/features/auth/data/auth_repository_impl_test.dart).

## Pendência ativa (bloqueio de backend, fora do escopo do app)

A causa raiz de por que a API retorna `token: null` num login bem-sucedido
para essa conta específica **não é um bug do app** — precisa ser investigada
por quem mantém a API (`POST /auth/login`). Possíveis causas: conta com
verificação de e-mail pendente, tipo de perfil sem permissão de app mobile,
ou bug genuíno no endpoint. Até isso ser corrigido, nenhuma conta consegue
completar login de verdade pelo app.

**Workaround mantido**: botão "Pular login (debug)" em
[`login_page.dart`](../../lib/features/auth/presentation/pages/login_page.dart),
visível apenas em `kDebugMode`, navega direto para `/` sem autenticar —
continua necessário até o backend corrigir o token nulo.

## Próximo passo

Reportar o payload acima para quem mantém a API. Depois disso, remover o
bypass de debug e validar o fluxo completo.
