# Autenticação (Login)

Status: ✅ Concluído — testado com login real de ponta a ponta ·
Commit: `b9e4ce0` (implementação inicial), `d87fecb` (migração pro contrato mobile)

## Escopo

Login apenas por email/senha na v1. Login social (Google, `/auth/google`)
fica para depois.

## Histórico

1. **Implementação inicial** contra `POST /auth/login` (token único).
2. **Bug do token nulo** (2026-08-18): a API respondia `200 OK` com
   `"token": null` em login válido; o DTO tratava o campo como obrigatório,
   o parse explodia com uma exceção que não era `DioException`, e a tela
   ficava presa em loading pra sempre sem erro. Corrigido tornando o campo
   nullable e retornando `Err(UnknownFailure(...))` quando vier nulo — mas
   a causa raiz (por que vinha nulo) era do backend, não do app.
3. **Contrato novo enviado pelo time da API** (2026-08-18, mesmo dia):
   `POST /auth/mobile/login` / `POST /auth/mobile/refresh` substituem o
   `/auth/login` antigo — resolve o bug do token nulo por completo, trocando
   para um par `accessToken`/`refreshToken` explícito.

## Arquitetura (contrato atual)

- `domain/`: `AuthSession` (campo `accessToken`), `ProfileType`,
  `AuthRepository`, `LoginUseCase`.
- `data/`: `LoginRequestDto` (`email`/`senha`) / `LoginResponseDto`
  (`accessToken`/`refreshToken`/`userId`/`profileType`/`permissions`, tudo
  nullable — ver nota de nullability abaixo), `AuthRemoteDatasource`
  (`POST /auth/mobile/login`), `AuthSessionMapper`, `AuthRepositoryImpl`.
- `TokenStorage` (`flutter_secure_storage`) guarda o par
  `accessToken`/`refreshToken` — a API sempre substitui os dois juntos.
- `AuthInterceptor` (dio): injeta `Authorization: Bearer <accessToken>` em
  toda chamada; num 401, renova via `POST /auth/mobile/refresh` (com
  `refreshToken` no body, não query param) — single-flight, então chamadas
  concorrentes esperam a mesma renovação em vez de disparar refreshes
  duplicados.
- O endpoint mobile sempre cria a sessão no contexto de **comprador**,
  mesmo para contas de fornecedor/franqueado/admin — por isso o mapper usa
  `profileType ?? ProfileTypeDto.customer` como fallback.

## Nota de nullability

Nenhum schema de resposta da API declara campos `required` — nem o
`LoginResponse` antigo, que foi exatamente o que causou o bug do token
nulo. `LoginResponseDto` trata todos os campos como nullable;
`AuthRepositoryImpl.login()` valida explicitamente que
`accessToken`/`refreshToken`/`userId` não são nulos antes de prosseguir,
retornando `Err(UnknownFailure(...))` com mensagem clara em vez de deixar
uma exceção de parse travar a tela.

## Validado

Login real testado no simulador com credenciais reais: autenticação,
carrinho anônimo mesclado na conta após login, endereços/pedidos reais
carregando no Perfil. Bypass de debug ("Pular login") continua disponível
(só em `kDebugMode`) para acelerar testes sem digitar credenciais toda
hora — não é mais necessário para login funcionar, é conveniência.
