import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cotação de uma moeda em reais, vinda da AwesomeAPI.
class Cotacao {
  final String codigo; // USD, EUR...
  final String nome; // "Dólar Americano/Real Brasileiro"
  final double valor; // quanto vale 1 unidade em R$ (campo "bid")
  final double variacao; // variação do dia em % (campo "pctChange")
  final String atualizadaEm; // "2026-11-09 11:30:00"

  const Cotacao({
    required this.codigo,
    required this.nome,
    required this.valor,
    required this.variacao,
    required this.atualizadaEm,
  });

  factory Cotacao.fromJson(Map<String, dynamic> json) {
    return Cotacao(
      codigo: json['code'] as String,
      nome: json['name'] as String,
      valor: double.parse(json['bid'].toString()),
      variacao: double.tryParse(json['pctChange'].toString()) ?? 0,
      atualizadaEm: (json['create_date'] ?? '').toString(),
    );
  }
}

/// Camada HTTP: só conversa com a API e devolve objetos Dart.
/// API pública, sem chave: https://docs.awesomeapi.com.br/api-de-moedas
class CotacaoService {
  static const baseUrl = 'https://economia.awesomeapi.com.br/json/last';

  final http.Client _client;

  CotacaoService({http.Client? client}) : _client = client ?? http.Client();

  /// Ex.: buscar(['USD', 'EUR']) -> GET /json/last/USD-BRL,EUR-BRL
  Future<Map<String, Cotacao>> buscar(List<String> codigos) async {
    final pares = codigos.map((c) => '$c-BRL').join(',');
    final resposta = await _client
        .get(Uri.parse('$baseUrl/$pares'))
        .timeout(const Duration(seconds: 10));

    if (resposta.statusCode != 200) {
      throw Exception('A API de cotações respondeu ${resposta.statusCode}.');
    }

    final json = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    final cotacoes = <String, Cotacao>{};
    for (final item in json.values) {
      final cotacao = Cotacao.fromJson(item as Map<String, dynamic>);
      cotacoes[cotacao.codigo] = cotacao;
    }
    return cotacoes;
  }
}
