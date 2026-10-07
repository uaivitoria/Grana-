# Grana+

App de controle financeiro pessoal — **Capstone Etapa 2 (só layout)**, squad **Granitos**.
Disciplina: Desenvolvimento para Ambientes Móveis (Flutter).

Integrantes: Vitória Campos, Sofia Purcino, Theo Purcino, Rafael Penna, Daniel Augusto Gonçalves.

Visual baseado no protótipo do Figma Make. Nesta etapa **não há integração**: sem `http`,
sem `SharedPreferences`, sem `Provider`. Todos os dados estão em `lib/data/dados_fake.dart`.

## Como rodar

```bash
flutter create . --project-name grana_mais --platforms=android,ios,web,windows   # só na 1ª vez: gera as pastas de plataforma
flutter pub get
flutter run
```

## Fluxo

```
Login (form) → Início ──→ Detalhe da movimentação
                 │
  menu inferior: Início · Análises · [+] Adicionar · Calendário · Perfil
                                         │              │           │
                                   Novo lançamento  Agendar conta  ├─ Editar perfil (form)
                                     (form)          (form)        └─ Carteira → Detalhe do cartão → Detalhe da movimentação
Perfil → "Sair da conta" volta ao Login
```

## Telas e responsáveis

| # | Tela (ficha) | Arquivo | Responsável |
|---|---|---|---|
| 1 | Login | `login_screen.dart`, `main_shell.dart` | Vitória Campos |
| 2 | Início | `home_screen.dart`, `transacao_detalhe_screen.dart` | Sofia Purcino |
| 3 | Adicionar | `adicionar_screen.dart` | Theo Purcino |
| 4 | Análises | `analises_screen.dart` | Rafael Penna |
| 5 | Calendário | `calendario_screen.dart`, `agendar_conta_screen.dart` | Rafael Penna |
| 6 | Perfil / Carteira | `perfil_screen.dart`, `editar_perfil_screen.dart`, `carteira_screen.dart`, `cartao_detalhe_screen.dart` | Daniel Augusto Gonçalves |

## Checklist da Etapa 2

- [x] Todas as 6 telas da ficha existem
- [x] Fluxo navegável a partir do Login (`Navigator.push` / `pop`)
- [x] Lista com ≥ 3 itens no Dart (`ListView.builder`): movimentações no Início, moedas no Adicionar, cartões na Carteira
- [x] Formulários com `Form` + `TextFormField` + `validator`: Login, Adicionar, Agendar conta, Editar perfil
- [x] Nenhum import de `http` nem de `shared_preferences`
- [x] Cada arquivo de tela tem o nome do responsável num comentário no topo
