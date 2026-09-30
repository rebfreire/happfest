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

Tanto `LoginPage` quanto `SignupPage` chegam sempre via `context.push`
(nunca são a rota inicial), então o `AppBar` padrão já resolve a seta de
voltar automática — sem isso, a tela de login era um ponto morto sem
como cancelar.

## Tela de login (redesenho)

`LoginPage` segue um layout fixo (título/subtítulo/labels — ver
referência visual usada no redesenho): logo, título ("Entrar"), subtítulo
("Escolha como deseja entrar na sua conta"), campos de E-mail/Senha com
label estático acima (não o label flutuante padrão do
`AppTextField` — por isso `AppTextField(label: '', hint: ...)` com um
`Text` separado acima), link "Esqueci minha senha", botão "Entrar" e o
rodapé "Não tem uma conta? Criar conta". Todo texto novo via l10n
(`loginTitle`, `loginSubtitle`, `loginEmailHint`, `loginPasswordHint`,
`loginForgotPassword`, `loginNoAccountQuestion`, `loginCreateAccountLink`
em `app_pt.arb`/`app_en.arb`) — nenhuma string nova hardcoded, conforme
AGENTS.md.

**Recuperação de senha**: "Esqueci minha senha" abre um diálogo
(`_ForgotPasswordDialog`, privado em `login_page.dart`) pré-preenchido
com o e-mail já digitado; ao confirmar, chama
`RequestPasswordResetUseCase` → `POST /auth/recuperar-senha?email=...`
(público). Isso cobre só a metade de **solicitar** o e-mail de
recuperação — a metade de **confirmar** a nova senha
(`POST /auth/redefinir-senha`, que recebe `{senha, token}`) ainda **não
está implementada**: exigiria tratar o deep link do e-mail para capturar
o `token`, o que ficou fora do escopo desta rodada.

## Home

O botão de atalho para a Design System (ícone de paleta, só em
`kDebugMode`) foi removido do `AppBar` da Home — não fazia sentido expor
uma tela de debug interna no header de produção.

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
- **Cadastro**: `POST /customers` (público, sem `Authorization`) →
  `CustomerResponse`. Esse endpoint não devolve token e **não loga
  automaticamente** — ver nota abaixo sobre verificação de e-mail.
  `SignupController`/`SignupPage` seguem o mesmo padrão de estados do
  `LoginController`/`LoginPage` (idle/loading/success/failure).

### Cadastro com provisionamento financeiro Asaas (2026-09-29)

O backend passou a criar automaticamente uma subconta financeira Asaas
para cada cliente cadastrado, e `POST /customers` (`CustomerRequest`
em `docs/api/openapi.json`, re-baixado de
`GET /api/v1/api-docs`) passou a exigir, além de
`nome`/`email`/`senha`/`cpf`/`phone`:

- `birthDate` (`YYYY-MM-DD`, sem conversão de fuso — formatado na mão em
  `SignupPage._formatDate`, não via `toIso8601String()`, pra não mudar o
  dia por causa de UTC).
- `incomeValue` (número > 0, não string formatada como moeda).
- `address` (`RegistrationAddressRequestDto`: `street`/`number`/
  `neighborhood`/`zipCode` obrigatórios, `complement` opcional,
  `cityCodigoIbge`/`stateCodigoUf` como códigos IBGE numéricos — nunca a
  sigla do estado).

O app **não fala com a Asaas diretamente e não guarda nenhuma chave
dela** — só envia os dados completos pro `POST /customers`; o
provisionamento é 100% responsabilidade do backend depois que o cliente é
persistido.

**Tela**: `SignupPage` virou um formulário em 3 etapas (dados de acesso →
dados pessoais → endereço), com indicador de progresso e navegação
Avançar/Voltar validando cada etapa antes de deixar avançar. O passo de
endereço reaproveita `CepAddressFields`/`StateCityPicker`
(`lib/core/location/`) — já existentes pra cadastro de endereço da conta
— que resolvem `cityCodigoIbge`/`stateCodigoUf` via CEP (ViaCEP) com
fallback pra seleção manual de estado/cidade (API pública do IBGE); CPF,
telefone e CEP são enviados só com dígitos (`_onlyDigits` remove
formatação antes do submit).

**DTOs**: `SignupRequestDto` (agora com `birthDate`/`incomeValue`/
`address`) e `RegistrationAddressRequestDto` (novo,
`lib/features/auth/data/dto/`). `SignupRequestDto` foi o primeiro DTO do
app com um campo aninhado que é ele mesmo um objeto serializável — sem
`explicit_to_json: true` (configurado globalmente em `build.yaml`, novo
arquivo), `toJson()` embutia o objeto Dart bruto de `address` em vez do
mapa serializado. A config é global mas inofensiva para o resto dos DTOs
(só primitivos) — se um novo DTO aninhado aparecer, já funciona sem
configuração extra.

**Erros**: os códigos 400/404/409/422 já eram tratados de forma genérica
pelo `error_mapper.dart` existente (mensagem do `ProblemDetail` da API
sempre que presente) — sem necessidade de tratamento específico para
cadastro. 409 cobre e-mail/CPF já cadastrados; 404, cidade/estado não
encontrados (não deveria acontecer no fluxo normal, já que os códigos vêm
resolvidos pelo CEP/picker); 422, validação de campo.

**Ativação de conta via login social** (`activated: false` em
`GET /customers/me/context`, `POST /customers/me/activate`): contrato
mapeado no OpenAPI, mas **não implementado** — o app não tem login
social (Google ou outro) hoje, então o gatilho dessa tela não existe.
Se um login social for adicionado no futuro, essa é a peça que falta.

**Sem auto-login após o cadastro** (bug encontrado ao vivo, corrigido no
mesmo dia): a primeira versão do cadastro com Asaas manteve o
comportamento antigo de logar automaticamente logo após
`POST /customers`, reaproveitando `login()`. Só que a API real passou a
**exigir e-mail verificado antes de autenticar** — o login imediato
sempre falha com 401/403 pedindo confirmação do e-mail, então o cadastro
aparecia como erro para o usuário mesmo tendo sido criado com sucesso.
Corrigido removendo o auto-login: `AuthRepository.signup()` agora
retorna `Future<Result<void>>` (só o resultado do `POST /customers`,
sem sessão), `SignupState.success()` não carrega mais `AuthSession`, e
`SignupPage` mostra um diálogo ("Conta criada! Verifique seu e-mail...")
antes de navegar para `/login` — sem tentar logar sozinha. Como
consequência, o merge do carrinho anônimo (`MergeCartUseCase`) saiu do
`SignupController`: não há mais sessão para mesclar nesse momento; o
merge volta a acontecer normalmente quando o usuário loga de fato depois
de verificar o e-mail (`LoginController` já faz isso).

Ao validar essa correção no simulador, o botão "Avançar" da primeira
etapa parou de responder a toques repetidamente (mesmo após várias
reinicializações completas do `flutter run`) — parecia um bug real na
transição de etapas. Descartado como bug de código: um novo widget test
(`test/widget/features/auth/signup_page_test.dart`) que preenche
nome/e-mail/senha válidos e toca "Avançar" via `WidgetTester` confirma
que a transição pra etapa de dados pessoais funciona corretamente. A
causa foi instabilidade de entrada do simulador (já documentada em
outras partes desta sessão), não algo no app.

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
