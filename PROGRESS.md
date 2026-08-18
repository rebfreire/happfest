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
| 2 | Autenticação (login email/senha) | ✅ App corrigido — ⚠️ bloqueado por bug no backend |
| 3 | Home (busca, categorias, grid de produtos) | ✅ Concluída |
| 4 | Detalhe do produto | ✅ Concluída |
| 5 | Carrinho | ✅ Concluída |
| 5.5 | Shell do app (bottom nav) | ✅ Concluída |
| 6 | Checkout | ⏳ Não iniciado |
| 7 | Conta (endereços, festas, pedidos) | ⏳ Não iniciado |
| 8 | Login social (Google) | ⏳ Não iniciado (fora da v1) |

Detalhes de cada feature em `docs/progress/`.

## Pendências conhecidas

- **Carrinho retorna "Algo deu errado"**: esperado enquanto o login estiver
  no bypass de debug — sem token real salvo, `POST /cart/items` volta 401 e
  cai no `UnknownFailure` genérico. Só será resolvido quando o backend
  corrigir o login (ver abaixo).
- **Login real bloqueado por bug no backend**: diagnosticado — a API responde
  `200 OK` num login válido mas com `"token": null` no corpo (confirmado via
  `curl` direto). O app foi corrigido para não travar mais nesse caso (antes
  ficava preso em loading para sempre, sem erro — uma exceção de parse não
  tratada; ver [`docs/progress/03-auth.md`](docs/progress/03-auth.md) para o
  diagnóstico completo) e agora mostra um erro claro. Mas o login real
  continua bloqueado até o backend corrigir o `token: null`. Enquanto isso, o
  botão "Pular login (debug)" na `LoginPage` (visível só em `kDebugMode`)
  continua necessário para testar o resto do app.
- **iOS**: flavors (dev/staging/prod) ainda não configurados como schemes
  separados no Xcode — hoje só existe o scheme default (bundle id
  `br.com.comcode.happfest`), com os 3 ambientes apontando para a mesma API
  de produção.
- **Firebase**: integrado defensivamente no código (`bootstrap.dart`), mas
  `flutterfire configure` ainda não foi rodado — não há projeto Firebase real
  configurado ainda.

## Como rodar

```bash
cd ~/Developer/happfest
fvm flutter run -d <device-id> --target=lib/main_dev.dart
```

## Próximos passos sugeridos

1. Reportar o bug do `token: null` para quem mantém a API; quando corrigido,
   validar o login real e remover o bypass de debug.
2. Checkout (fluxo multi-step: Itens → Festa → Entrega → Resumo, conforme o
   site atual).
3. Área de conta (endereços, festas, pedidos) — substituirá os placeholders
   das abas Categorias/Festas/Perfil do shell.
4. Configurar flavors no Xcode e `flutterfire configure`.
