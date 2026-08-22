# HappFest — Progresso do App Flutter (Comprador)

Última atualização: 2026-08-18

## Visão geral

App nativo Flutter (iOS + Android) recriando o marketplace HappFest para o
**comprador final**. Segue a arquitetura definida em [`AGENTS.md`](./AGENTS.md)
(Clean Architecture feature-first, Riverpod, go_router, dio, freezed) e consome
a API real de produção (`https://happ-api.comcode.com.br/api/v1`).

O app do fornecedor é um projeto separado, a ser iniciado depois.

## Status por fase

| Fase | Descrição | Status |
|---|---|---|
| 0 | Setup (flavors, lints, CI, estrutura de pastas, Firebase) | ✅ Concluída |
| 1 | Design System (tokens + catálogo de componentes) | ✅ Concluída |
| 2 | Autenticação (login mobile: access + refresh token) | ✅ Concluída — testada com login real |
| 3 | Home (busca, categorias, grid de produtos) | ✅ Concluída |
| 4 | Detalhe do produto | ✅ Concluída |
| 5 | Carrinho (com merge do carrinho anônimo no login) | ✅ Concluída |
| 5.5 | Shell do app (bottom nav) | ✅ Concluída |
| 6 | Categorias (navegação em árvore + produtos) | ✅ Concluída |
| 7 | Conta (perfil, endereços CRUD, detalhe de pedido) | ✅ Concluída |
| 8 | Festas (listar + criar) | ✅ Concluída |
| 9 | Checkout (Itens → Festa → Entrega → Resumo) | ✅ Concluído — ⚠️ não validado ao vivo ainda |
| 10 | Login social (Google) | ⏳ Não iniciado (fora da v1) |

Detalhes de cada feature em `docs/progress/`.

## Pendências conhecidas

- **Checkout ainda não validado ao vivo**: código completo e coberto por
  unit tests, mas o fluxo de ponta a ponta (preview → confirmar pedido →
  link de pagamento) ainda não foi confirmado no simulador contra a API
  real. Ver [`docs/progress/11-checkout.md`](docs/progress/11-checkout.md).
- **Entrega por loja no checkout**: hoje toda loja herda a entrega da festa
  selecionada; personalizar endereço/data por loja individualmente
  (`SubOrderDeliveryRequest`) fica para depois.
- **Editar endereço**: só criar/excluir/definir padrão têm UI — falta o
  `PUT /customers/me/addresses/{id}`.
- **Editar/arquivar festa**: a API não expõe esses endpoints — só
  criar/listar são possíveis no contrato atual.
- **Contrato da API (`docs/api/openapi.json`) não declara nenhum campo como
  `required` em nenhum schema de resposta** (nem no `LoginResponse`, que já
  causou o bug do token nulo no contrato antigo). Os DTOs das features mais
  recentes (Conta, Festas, Categorias, Checkout) tratam só `id` como
  obrigatório e todo o resto como nullable/com default, por segurança. Os
  DTOs mais antigos (produto, carrinho, categoria) ainda não passaram por
  essa auditoria — funcionam bem com dados reais até agora, mas vale
  revisar se aparecerem novos casos de tela travando sem erro.
- **iOS**: flavors (dev/staging/prod) ainda não configurados como schemes
  separados no Xcode — hoje só existe o scheme default (bundle id
  `br.com.comcode.happfest`), com os 3 ambientes apontando para a mesma API
  de produção.
- **Firebase**: integrado defensivamente no código (`bootstrap.dart`), mas
  `flutterfire configure` ainda não foi rodado — não há projeto Firebase real
  configurado ainda.
- **Bypass de login (debug)**: botão "Pular login (debug)" ainda presente
  na `LoginPage` (só em `kDebugMode`, não vai pra release). Como o login
  real já funciona, pode ser removido quando quiser — mantido por
  enquanto para agilizar testes sem precisar digitar credenciais toda hora.

## Como rodar

```bash
cd ~/Developer/happfest
fvm flutter run -d <device-id> --target=lib/main_dev.dart
```

## Próximos passos sugeridos

1. Validar o Checkout de ponta a ponta no simulador (preview, confirmação,
   link de pagamento).
2. Entrega por loja no checkout (override de endereço/data individual).
3. Editar endereço.
4. Configurar flavors no Xcode e `flutterfire configure`.
5. Remover o bypass de debug quando o time estiver confiante no login real.
