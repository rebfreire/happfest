# Autenticação (Login + Cadastro)

Status: ✅ Concluído — testado com login real de ponta a ponta ·
Commit: `b9e4ce0` (implementação inicial), `d87fecb` (migração pro contrato mobile)

## Escopo

Login e cadastro por email/senha na v1. Login social (Google,
`/auth/mobile/google`) fica para depois.

## Fluxo de navegação (sem gate no início)

O app **não pede login para navegar** — `initialLocation` do router é a
Home (`/`), e Home/Categorias/Produto/Carrinho funcionam para visitante,
com o carrinho anônimo via `X-Cart-Session-Id` (ver `CartSessionInterceptor`).
Login só é pedido quando uma ação realmente exige conta:

- **Finalizar compra** ([`CartPage._goToCheckout`](../../lib/features/cart/presentation/pages/cart_page.dart)):
  sem token salvo, abre `/login` (com `extra: '/checkout'` como
  `returnTo`) em vez de ir direto pro checkout.
- **Cadastrar festa** ([`PartiesPage._newParty`](../../lib/features/parties/presentation/pages/parties_page.dart)):
  mesmo padrão, `returnTo: '/festas/novo'`.
- **Abas Perfil/Festas sem login**: em vez do erro genérico de sessão
  expirada, mostram um `AppEmptyState` com botão "Fazer login" quando a
  API responde 401 (`UnauthorizedFailure`) — ver `AccountPage`/
  `PartiesPage`.

Em todos os casos, `LoginPage`/`SignupPage` recebem `returnTo` (via
`extra` da rota) e navegam de volta pra lá ao concluir — sem `returnTo`,
segue pra Home. A tela de login também tem um botão "Criar conta" que
leva pra `/cadastro`, carregando o mesmo `returnTo`.

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
- **Cadastro**: `SignupRequestDto` (`nome`/`email`/`senha`/`cpf`/`phone`) →
  `POST /customers` (público, sem `Authorization`) → `CustomerResponse`.
  Esse endpoint não devolve token — `AuthRepositoryImpl.signup()` chama o
  `login()` normal em seguida com as mesmas credenciais para obter a
  sessão, reaproveitando toda a lógica de validação/merge de carrinho já
  existente. `SignupController`/`SignupPage` seguem o mesmo padrão do
  `LoginController`/`LoginPage`.

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
