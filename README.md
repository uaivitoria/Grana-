# Grana+

## 1. Identificação

- **App:** Grana+ — controle financeiro pessoal
- **Squad:** Granitos
- **Disciplina:** Desenvolvimento para Ambientes Móveis (Flutter) — Capstone A3

| Integrante | Matrícula | Contato |
|---|---|---|
| Vitória Campos | 72401290 | 72401290@aluno.faculdadecotemig.br |
| Sofia Purcino Campelo | 72500280 | 72500280@aluno.faculdadecotemig.br |
| Theo Purcino Campelo | 72500271 | 72500271@aluno.faculdadecotemig.br |
| Rafael Penna | 72500824 | 72500824@aluno.faculdadecotemig.br |

## 2. Sobre o projeto

O Grana+ ajuda estudantes e jovens adultos a organizar a vida financeira no celular.
O aluno entra com a **conta do Portal Cotemig** (login validado na API do Cotemig). Depois do login, o **Início** mostra o saldo, entradas, saídas, gastos no cartão, as
**cotações do dia** (dólar, euro e libra, buscadas numa API pública) e a lista das últimas
movimentações. Pelo botão **+** a pessoa lança uma despesa ou receita, inclusive em moeda
estrangeira, convertida para reais pela cotação do dia. O **Calendário** mostra e agenda contas
a pagar/receber. No **Perfil** dá para editar os dados (o endereço é preenchido pelo CEP via
ViaCEP) e ver a **Carteira** com contas e cartões. Lançamentos, contas agendadas, perfil e
usuário logado ficam salvos no aparelho e continuam lá ao reabrir o app.

Fluxo principal:

```
Login (form) → Início ──→ Detalhe da movimentação (excluir)
                 │
  menu inferior: Início · Análises · [+] Adicionar · Calendário · Perfil
                                         │              │           │
                                   Novo lançamento  Agendar conta  ├─ Editar perfil (form + ViaCEP)
                                     (form)          (form)        └─ Carteira → Detalhe do cartão → Detalhe da movimentação
Perfil → "Sair da conta" apaga a sessão e volta ao Login
```

## 3. Requisitos atendidos

| # | Requisito | Onde está |
|---|---|---|
| 1 | ≥ 4 telas com `Navigator.push` / `pop` | Login → Início → Detalhe; Adicionar; Calendário → Agendar; Perfil → Editar perfil / Carteira → Detalhe do cartão (`lib/screens/`) |
| 2 | API REST com `http` + `async/await` | `lib/services/cotemig_service.dart` (login Cotemig), `lib/services/cotacao_service.dart` (AwesomeAPI) e `lib/services/viacep_service.dart` (ViaCEP) |
| 3 | Loading e erro visíveis | Login: botão "Entrando…" com spinner e mensagem de erro da API (ex.: "Usuário ou senha não conferem."); card "Cotações do dia" no Início (`lib/widgets/cotacoes_card.dart`): spinner, mensagem de erro e botão "Tentar de novo"; busca de CEP em Editar perfil (spinner no campo + erro "CEP não encontrado") |
| 4 | `Form` + `validator` | Login, Novo lançamento, Agendar conta, Editar perfil |
| 5 | `ListView.builder` | Últimas movimentações (Início), cartões (Carteira), moedas (Novo lançamento) |
| 6 | `SharedPreferences` persiste | `lib/services/storage_service.dart`: sessão (usuário, nome e token do Cotemig — a senha não é salva), lançamentos, contas agendadas e perfil |
| 7 | Provider separando telas, HTTP e prefs | `lib/providers/` (estado) ← telas usam `context.watch/read`; providers chamam `lib/services/` (HTTP e prefs). Registro em `lib/main.dart` (`MultiProvider`) |
| 8 | Abre e percorre o fluxo sem crashar | Testado em `test/fluxo_test.dart` (fluxo completo) e `test/providers_test.dart` |

## 4. API e dados remotos

**APIs públicas** (não há backend próprio). Nenhuma precisa de chave; a do Cotemig exige
usuário e senha do Portal Cotemig.

| API | URL base | Endpoint usado | Uso no app |
|---|---|---|---|
| COTEMIG API ([doc](https://api-dev.cotemig.com.br/v1/doc/)) | `https://api-dev.cotemig.com.br/v1` | `POST /autenticacao` (Basic auth usuário:senha → `{ token }`), `GET /perfil` (Bearer token → nome e e-mail), `POST /sair` (invalida o token) | Login, nome na saudação e no perfil, logout |
| AwesomeAPI (cotações) | `https://economia.awesomeapi.com.br/json/last` | `GET /USD-BRL,EUR-BRL,GBP-BRL,ARS-BRL,JPY-BRL,CAD-BRL` | Cotações do dia no Início e conversão de moeda no Novo lançamento |
| ViaCEP | `https://viacep.com.br/ws` | `GET /{cep}/json/` (ex.: `/30140071/json/`) | Preencher endereço em Editar perfil |

Se a AwesomeAPI falhar (sem internet ou limite de requisições), o Início mostra o erro com
"Tentar de novo" e o Novo lançamento usa uma taxa de referência fixa, avisando na tela.

**Login de teste:** usar a matrícula/usuário e a senha do Portal Cotemig de um integrante do
squad. Senha errada mostra "Usuário ou senha não conferem." (resposta 401 da API).

## 5. Como rodar

Pré-requisito: Flutter **3.35 ou mais novo** (canal stable, Dart ≥ 3.4).
Verifique com `flutter --version`.

```bash
flutter pub get
flutter run              # escolhe o dispositivo conectado/emulador
flutter run -d chrome    # ou no navegador
flutter test             # testes automatizados
```

Plataformas: Android (emulador ou celular) e Web (Chrome). As pastas `android/`, `ios/`, `web/` e
`windows/` já estão no projeto.

## 6. Backend local

Não se aplica — o app usa apenas APIs públicas.

## 7. Estrutura do código

```
lib/
  main.dart            MultiProvider + escolha da tela inicial (login ou Início)
  data/dados_fake.dart Modelos (Transacao, ContaAgendada...) + dados iniciais da 1ª abertura
  services/            Acesso externo: HTTP (cotações, ViaCEP) e SharedPreferences
  providers/           Estado do app (ChangeNotifier): sessão, lançamentos, agenda, perfil, cotações
  screens/             Telas
  widgets/             Componentes reutilizados (logo, card de resumo, card de cotações)
  theme/               Cores, tema e formatação de R$
test/                  Testes de widget (fluxo) e dos providers (persistência, API ok/erro)
```

| Responsável | Telas | Arquivos |
|---|---|---|
| Vitória Campos | Login, menu inferior, Perfil | `login_screen.dart`, `main_shell.dart`, `perfil_screen.dart` |
| Sofia Purcino | Início, Detalhe da movimentação, Detalhe do cartão | `home_screen.dart`, `transacao_detalhe_screen.dart`, `cartao_detalhe_screen.dart` |
| Theo Purcino | Adicionar, Editar perfil, Carteira | `adicionar_screen.dart`, `editar_perfil_screen.dart`, `carteira_screen.dart` |
| Rafael Penna | Análises, Calendário, Agendar conta | `analises_screen.dart`, `calendario_screen.dart`, `agendar_conta_screen.dart` |

## 8. Observações

- **Login** usa a API do Cotemig; o token dura 90 dias e fica salvo, então o app não pede login de novo até "Sair da conta".
- **Análises** ainda aparece como "Em breve".
- **Carteira** (contas e cartões) usa dados de exemplo; o cadastro de conta/cartão não foi feito.
- O seletor de mês do Início só troca o rótulo; os totais consideram todos os lançamentos.
- Na primeira abertura o app carrega lançamentos e contas de exemplo, que podem ser excluídos.
- A AwesomeAPI tem limite de requisições por IP; se estourar, o app mostra o erro e usa taxa de referência.
