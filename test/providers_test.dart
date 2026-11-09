import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grana_mais/data/dados_fake.dart';
import 'package:grana_mais/providers/agenda_provider.dart';
import 'package:grana_mais/providers/cotacoes_provider.dart';
import 'package:grana_mais/providers/transacoes_provider.dart';
import 'package:grana_mais/services/cotacao_service.dart';
import 'package:grana_mais/services/storage_service.dart';
import 'package:grana_mais/services/viacep_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('lançamento novo continua lá ao "reabrir" o app', () async {
    final storage = StorageService();
    final primeiro = TransacoesProvider(storage);
    await primeiro.carregar();
    final antes = primeiro.transacoes.length;

    await primeiro.adicionar(const Transacao(
      titulo: 'Mercado',
      categoria: 'Alimentação',
      data: '09/11/2026',
      valor: -150,
      formaPagamento: 'Pix',
      icone: Icons.restaurant,
    ));

    // Novo provider = app reaberto, lendo do SharedPreferences.
    final reaberto = TransacoesProvider(storage);
    await reaberto.carregar();
    expect(reaberto.transacoes.length, antes + 1);
    expect(reaberto.transacoes.first.titulo, 'Mercado');
    expect(reaberto.transacoes.first.icone, Icons.restaurant);
  });

  test('conta agendada é persistida', () async {
    final storage = StorageService();
    final agenda = AgendaProvider(storage);
    await agenda.carregar();
    await agenda.adicionar(const ContaAgendada(7, 'Internet', 99, 'vencimento'));

    final reaberta = AgendaProvider(storage);
    await reaberta.carregar();
    expect(reaberta.doDia(7).single.descricao, 'Internet');
  });

  test('cotações: sucesso e erro', () async {
    final ok = CotacoesProvider(CotacaoService(
      client: MockClient((_) async => http.Response.bytes(
            utf8.encode(jsonEncode({
              'USDBRL': {
                'code': 'USD',
                'name': 'Dólar',
                'bid': '5.5',
                'pctChange': '1',
                'create_date': '2026-11-09',
              },
            })),
            200,
          )),
    ));
    await ok.carregar();
    expect(ok.estado, EstadoCarga.sucesso);
    expect(ok.valorEmReais(moedas.firstWhere((m) => m.codigo == 'USD')), 5.5);

    final falha = CotacoesProvider(CotacaoService(
      client: MockClient((_) async => http.Response('', 503)),
    ));
    await falha.carregar();
    expect(falha.estado, EstadoCarga.erro);
    expect(falha.erro, isNotNull);
  });

  test('ViaCEP: CEP inexistente vira erro amigável', () async {
    final service = ViaCepService(
      client: MockClient(
        (_) async => http.Response(jsonEncode({'erro': 'true'}), 200),
      ),
    );
    await expectLater(service.buscar('00000-000'), throwsException);
  });
}
