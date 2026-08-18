# Design System

Status: ✅ Concluído · Commit: `b9e4ce0`

## Tokens

Extraídos ao vivo do CSS computado do site de produção
(`https://happ-marketplace.comcode.com.br/`), não do protótipo
`vibrant_celebration`:

- Cores: `primary #FF3F81`, `secondary #3F8CFF`, `accent #2DF3A1`, paleta de
  superfície em escala slate, tema PrimeNG estilo "Aura".
- Fonte: `Quicksand`.
- Raios pequenos (form field 6px, modal 12px, popover 6px), sombras leves.

## Catálogo de componentes (`lib/design_system/`)

- Botões: `AppButton` (variantes primary/secondary/tertiary/danger/ghost,
  tamanhos, estado loading).
- Formulário: `AppTextField`, `AppFormLayout`, `AppCheckbox`, `AppSwitch`,
  `AppDropdown`, `AppRadioGroup`, `AppSearchField`.
- Layout: `AppScaffold`, `AppCard`, `AppListTile`, `AppChip`, `AppBadge`,
  `AppAvatar`, `AppPagedListView`.
- Feedback: `AppDialog`, `AppBottomSheet`, `AppSnackbar`, `AppLoading`,
  `AppEmptyState`, `AppErrorState`, `AsyncValueWidget`.
- Catálogo visual navegável em `/dev/design-system` (rota debug-only, atrás
  de `kDebugMode`).

## Notas

- `very_good_analysis` como base de lint, com 2 overrides locais em
  `analysis_options.yaml`: `sort_pub_dependencies: false` (SDK deps do
  Flutter precisam vir primeiro) e `one_member_abstracts: false`
  (interfaces de repositório são propositalmente single-method).
