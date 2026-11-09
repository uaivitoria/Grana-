import 'dart:convert';

import 'package:http/http.dart' as http;

/// Resultado de um login bem-sucedido na API do Cotemig.
class LoginCotemig {
  final String usuario;
  final String token; // Bearer token devolvido por /autenticacao
  final String nome; // nome completo, de /perfil
  final String email;

  const LoginCotemig({
    required this.usuario,
    required this.token,
    required this.nome,
    required this.email,
  });
}

/// Erro de login com mensagem pronta para mostrar na tela.
class LoginException implements Exception {
  final String mensagem;
  const LoginException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Camada HTTP do login. Doc: https://api-dev.cotemig.com.br/v1/doc/
///  1) POST /autenticacao com Basic auth (usuário:senha) -> { token }
///  2) GET  /perfil com `Authorization: Bearer TOKEN`     -> { nome, email, ... }
class CotemigService {
  static const baseUrl = 'https://api-dev.cotemig.com.br/v1';

  final http.Client _client;

  CotemigService({http.Client? client}) : _client = client ?? http.Client();

  Future<LoginCotemig> entrar(String usuario, String senha) async {
    final basic = base64Encode(utf8.encode('$usuario:$senha'));

    final http.Response auth;
    try {
      auth = await _client
          .post(
            Uri.parse('$baseUrl/autenticacao'),
            headers: {
              'Authorization': 'Basic $basic',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'longaDuracao': true}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const LoginException(
          'Sem conexão com o Cotemig. Verifique sua internet.');
    }

    if (auth.statusCode == 307) {
      throw const LoginException(
          'Há uma pesquisa pendente no Portal Cotemig. Responda lá e tente de novo.');
    }
    if (auth.statusCode != 200) {
      throw LoginException(_mensagemDeErro(auth));
    }

    final token = (_json(auth)['token'] ?? '') as String;
    if (token.isEmpty) {
      throw const LoginException('O Cotemig não devolveu o token de acesso.');
    }

    // Busca o nome do aluno. Se falhar, segue com o usuário mesmo.
    var nome = usuario;
    var email = '';
    try {
      final perfil = await _client.get(
        Uri.parse('$baseUrl/perfil'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));
      if (perfil.statusCode == 200) {
        final json = _json(perfil);
        nome = (json['nome'] as String?)?.trim() ?? usuario;
        email = (json['email'] as String?) ?? '';
      }
    } catch (_) {}

    return LoginCotemig(usuario: usuario, token: token, nome: nome, email: email);
  }

  /// Invalida o token no servidor (melhor esforço: ignora falhas).
  Future<void> sair(String token) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/sair'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  Map<String, dynamic> _json(http.Response r) =>
      jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;

  String _mensagemDeErro(http.Response r) {
    try {
      final detalhes = _json(r)['detalhes'];
      if (detalhes is String && detalhes.isNotEmpty) return detalhes;
    } catch (_) {}
    if (r.statusCode == 401) return 'Usuário ou senha não conferem.';
    return 'O Cotemig respondeu ${r.statusCode}. Tente de novo mais tarde.';
  }
}
