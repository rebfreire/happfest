# Relatório QA HappFest Buyer (29/10/2026): front x API

Análise dos 20 apontamentos do relatório de QA, separando o que é do app Flutter do que é da API/backend. As correções do front estão no PR #2 (`fix/qa-buyer-2026-10-29`).

## Resumo
- **16 bugs do front:** corrigidos neste branch.
- **1 misto (BUG-008):** o front tem um paliativo, mas a solução completa depende da API.
- **3 do backend/web (BUG-016, 017, 018):** não fazem parte do app Flutter.

## Front: corrigidos

| Bug | Sev. | Causa | Correção |
|---|---|---|---|
| 003 Preço R$ 1,00 | Crítica | Exibia `pricingUnitMin`, que é a quantidade mínima da unidade, como preço | Exibe `finalPrice`/`price` da variante padrão |
| 004 Crash em serviço | Crítica | `AppLoading.skeleton()` era um `ListView` sem altura definida dentro de outro `ListView` | `shrinkWrap` + `NeverScrollableScrollPhysics` |
| 007 Tela vermelha no cartão (web) | Crítica | `webview_flutter` não tem implementação para web | Na web, abre o checkout numa nova aba (`url_launcher`) |
| 001 Crash no Perfil | Alta | O tema do `TextButton` usava `Size.fromHeight(48)`, que dá largura infinita | `Size(64, 48)` |
| 020 Preso nas subcategorias | Alta | O breadcrumb quebrava pela mesma causa do 001 e não havia botão voltar | Botão voltar, voltar do sistema e reset ao tocar de novo na aba |
| 002 Perfil/Festas "deslogado" | Alta | O login invalidava só o carrinho | Login e logout invalidam perfil, endereços, pedidos e festas |
| 005/006/015 Nova Festa | Média | CEP com traço e "1.000" falhavam na validação; data inválida sem mensagem | Normaliza para dígitos e mostra erro inline nas datas |
| 009/014 Campos mascarados | Média | `AppTextField` reaproveitava `_obscured` do campo de senha | `didUpdateWidget` + `KeyedSubtree` por etapa |
| 010–013 Cadastro | Média/Baixa | Sem limites, data em ISO na tela, sem idade mínima, sem filtro de dígitos | `maxLength`, DD/MM/AAAA, 18+ anos, `digitsOnly` |
| 019 Carrinho vazio | Baixa | Sem botão de ação | Botão "Explorar produtos" |

## Misto: depende da API
- **BUG-008, duplicidade de e-mail/CPF só na 3ª etapa.** O OpenAPI não tem endpoint para verificar se o e-mail ou CPF já existe; a unicidade só é validada no `POST /customers` (409).
  - **Front (feito):** com o 409, o app volta para a etapa do campo e marca o erro nele.
  - **Pedido à API:** criar `GET /customers/availability?email=&cpf=`, com rate limit para evitar enumeração de usuários. Com ele, o app passa a verificar ao sair do campo.
- **BUG-012, idade mínima.** O app já bloqueia menores de 18 anos, mas é regra jurídica: o `POST /customers` também precisa rejeitar.

## Backend/web: não é do app Flutter
- **BUG-016/017:** página web de redefinir senha. O popover cobre o campo "Confirmar senha" e o indicador de força aparece em inglês ("Weak/Medium/Strong").
- **BUG-018:** template do e-mail de recuperação com o logo quebrado e sem acentos, provavelmente charset/encoding do e-mail.
