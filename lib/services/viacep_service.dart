import 'dart:convert';

import 'package:http/http.dart' as http;

/// Endereço devolvido pelo ViaCEP.
class EnderecoCep {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;

  const EnderecoCep({
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  /// Ex.: "Avenida Afonso Pena — Centro, Belo Horizonte/MG"
  String get resumo {
    final rua = logradouro.isEmpty ? '' : '$logradouro — ';
    final bairroTxt = bairro.isEmpty ? '' : '$bairro, ';
    return '$rua$bairroTxt$cidade/$uf';
  }
}

/// Camada HTTP do CEP. API pública, sem chave: https://viacep.com.br
class ViaCepService {
  static const baseUrl = 'https://viacep.com.br/ws';

  final http.Client _client;

  ViaCepService({http.Client? client}) : _client = client ?? http.Client();

  Future<EnderecoCep> buscar(String cep) async {
    final digitos = cep.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 8) {
      throw Exception('O CEP deve ter 8 números.');
    }

    final resposta = await _client
        .get(Uri.parse('$baseUrl/$digitos/json/'))
        .timeout(const Duration(seconds: 10));

    if (resposta.statusCode != 200) {
      throw Exception('O ViaCEP respondeu ${resposta.statusCode}.');
    }

    final json = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    if (json['erro'] != null) {
      throw Exception('CEP não encontrado.');
    }

    return EnderecoCep(
      logradouro: (json['logradouro'] ?? '') as String,
      bairro: (json['bairro'] ?? '') as String,
      cidade: (json['localidade'] ?? '') as String,
      uf: (json['uf'] ?? '') as String,
    );
  }
}
