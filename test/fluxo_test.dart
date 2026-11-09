import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grana_mais/main.dart';
import 'package:grana_mais/screens/adicionar_screen.dart';
import 'package:grana_mais/services/cotacao_service.dart';
import 'package:grana_mais/services/cotemig_service.dart';
import 'package:grana_mais/services/viacep_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resposta no mesmo formato da AwesomeAPI.
final respostaCotacoes = jsonEncode({
  'USDBRL': {
    'code': 'USD',
    'name': 'Dólar Americano/Real Brasileiro',
    'bid': '5.4321',
    'pctChange': '0.35',
    'create_date': '2026-11-09 10:00:00',
  },
  'EURBRL': {
    'code': 'EUR',
    'name': 'Euro/Real Brasileiro',
    'bid': '6.1',
    'pctChange': '-0.2',
    'create_date': '2026-11-09 10:00:00',
  },
});

/// API do Cotemig falsa: aceita joao/1234.
final cotemigFalso = MockClient((req) async {
  http.Response json(Object corpo, int status) =>
      http.Response.bytes(utf8.encode(jsonEncode(corpo)), status);

  if (req.url.path.endsWith('/autenticacao')) {
    final esperado = 'Basic ${base64Encode(utf8.encode('joao:1234'))}';
    if (req.headers['Authorization'] == esperado) {
      return json({'token': 'token-teste', 'longaDuracao': true}, 200);
    }
    return json({
      'erro': 401,
      'codigo': 103,
      'detalhes': 'Usuário ou senha não conferem.',
    }, 401);
  }
  if (req.url.path.endsWith('/perfil')) {
    return json({'nome': 'JOAO DA SILVA', 'email': 'joao@cotemig.com.br'}, 200);
  }
  return json({}, 200);
});

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('login valida e percorre as abas sem crashar', (tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final apiFalsa = MockClient(
      (_) async => http.Response.bytes(utf8.encode(respostaCotacoes), 200),
    );
    await tester.pumpWidget(GranaMaisApp(
      cotacaoService: CotacaoService(client: apiFalsa),
      viaCepService: ViaCepService(client: apiFalsa),
      cotemigService: CotemigService(client: cotemigFalso),
    ));
    await tester.pumpAndSettle();

    // Formulário vazio -> validator reclama
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Informe seu nome de usuário.'), findsOneWidget);

    // Senha errada -> erro da API aparece na tela
    await tester.enterText(find.byType(TextFormField).at(0), 'joao');
    await tester.enterText(find.byType(TextFormField).at(1), 'errada');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Usuário ou senha não conferem.'), findsOneWidget);

    // Senha certa -> abre o Início com o nome vindo do /perfil
    await tester.enterText(find.byType(TextFormField).at(1), '1234');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Joao'), findsOneWidget);

    // Sessão (com token) ficou salva no SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sessao'), contains('token-teste'));

    // Cotação veio da "API"
    await tester.scrollUntilVisible(find.text('Cotações do dia'), 200);
    expect(find.text('USD'), findsOneWidget);

    // Lista -> detalhe -> volta
    final netflix = find.text('Netflix');
    await tester.scrollUntilVisible(netflix, 200);
    await tester.runAsync(() => Scrollable.ensureVisible(
          tester.element(netflix),
          alignment: 0.5,
        ));
    await tester.pumpAndSettle();
    await tester.tap(netflix);
    await tester.pumpAndSettle();
    expect(find.text('Detalhe da movimentação'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Abas do menu inferior
    for (final aba in ['Análises', 'Calendário', 'Perfil', 'Início']) {
      await tester.tap(find.text(aba).last);
      await tester.pumpAndSettle();
    }

    // Botão + abre Adicionar e o validator funciona
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('Novo lançamento'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Salvar despesa'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(AdicionarScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Salvar despesa'));
    await tester.pump();
    expect(find.text('Informe o valor.'), findsOneWidget);
  });

  testWidgets('API fora do ar mostra erro e botão de tentar de novo',
      (tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'sessao': jsonEncode(
          {'usuario': 'maria', 'nome': 'MARIA SOUZA', 'token': 'abc'}),
    });

    final apiQuebrada = MockClient((_) async => http.Response('erro', 500));
    await tester.pumpWidget(GranaMaisApp(
      cotacaoService: CotacaoService(client: apiQuebrada),
      viaCepService: ViaCepService(client: apiQuebrada),
    ));
    await tester.pumpAndSettle();

    // Já estava logada: abre direto no Início
    expect(find.text('Olá, Maria'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Tentar de novo'), 200);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });
}
