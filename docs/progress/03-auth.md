# Autenticação (Login)

Status: ✅ Implementado · ⚠️ Login real ainda não validado end-to-end ·
Commit: `b9e4ce0`

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

## Pendência ativa

Ao testar com credenciais reais no simulador iOS, o fluxo de login não
completou como esperado. Ainda não diagnosticado se é:
- erro genuíno da API/credenciais, ou
- bug em `AuthRepositoryImpl`/`LoginController`/`LoginPage`.

**Workaround temporário**: botão "Pular login (debug)" em
[`login_page.dart`](../../lib/features/auth/presentation/pages/login_page.dart),
visível apenas em `kDebugMode`, navega direto para `/` sem autenticar. Serve
para continuar validando o resto do app enquanto o login real é investigado
separadamente. Não vai para build de release (bloqueado por `kDebugMode`),
mas precisa ser removido depois que o login real for confirmado funcionando.

## Próximo passo

Diagnosticar a causa raiz do erro de login com o dio/API real (logs de
`PrettyLogInterceptor` em debug, checar payload exato de `/auth/login` vs.
o que a API espera) e então remover o botão de bypass.
