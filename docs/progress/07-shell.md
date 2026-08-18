# Shell do app (navegação inferior)

Status: ✅ Concluído · Commit: (pendente)

## Contexto

Faltava a etapa "Shell do app" prevista entre Autenticação e as features —
ela tinha sido pulada na sequência original, e por isso o app não tinha a
barra de navegação inferior presente nos protótipos de referência
(`Desgin/home_happfest/code.html`).

## Arquitetura

- [`AppShellPage`](../../lib/app/shell/app_shell_page.dart): `Scaffold` com
  `NavigationBar` (Material 3) fixa no rodapé, 5 destinos — Home, Categorias,
  Carrinho, Festas, Perfil — replicando os ícones/labels do protótipo.
- [`app_router.dart`](../../lib/app/router/app_router.dart): usa
  `StatefulShellRoute.indexedStack` com 5 `StatefulShellBranch`, cada uma
  preservando sua própria pilha de navegação ao trocar de aba. `/login`,
  `/products/:id` e `/dev/design-system` ficam fora do shell (sem barra
  inferior).
- [`ComingSoonPage`](../../lib/app/shell/coming_soon_page.dart): placeholder
  reutilizável (`AppScaffold` + `AppEmptyState`) para as abas Categorias,
  Festas e Perfil, cujas features ainda não foram construídas.

## Pendências

Categorias, Festas e Perfil hoje são placeholders "em breve" — serão
substituídos pelas features reais (navegação por categoria, gestão de
festas, área de conta) nas próximas etapas.
