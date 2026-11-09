import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/dados_fake.dart';

/// Camada de persistência: tudo que o app salva no aparelho passa por aqui.
/// As telas não usam SharedPreferences diretamente; os Providers usam esta classe.
class StorageService {
  static const _chaveSessao = 'sessao';
  static const _chaveTransacoes = 'transacoes';
  static const _chaveAgenda = 'contas_agendadas';
  static const _chavePerfil = 'perfil';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---------- Sessão (usuário, nome e token do Cotemig; a senha NÃO é salva) ----------

  Future<Map<String, String>?> lerSessao() async {
    final texto = (await _prefs).getString(_chaveSessao);
    if (texto == null) return null;
    final mapa = jsonDecode(texto) as Map<String, dynamic>;
    return mapa.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> salvarSessao({
    required String usuario,
    required String nome,
    required String token,
  }) async {
    final texto = jsonEncode({'usuario': usuario, 'nome': nome, 'token': token});
    await (await _prefs).setString(_chaveSessao, texto);
  }

  Future<void> apagarSessao() async {
    await (await _prefs).remove(_chaveSessao);
  }

  // ---------- Lançamentos ----------

  /// Devolve null se o app nunca salvou lançamentos (primeira abertura).
  Future<List<Transacao>?> lerTransacoes() async {
    final texto = (await _prefs).getString(_chaveTransacoes);
    if (texto == null) return null;
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((e) => Transacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> salvarTransacoes(List<Transacao> transacoes) async {
    final texto = jsonEncode(transacoes.map((t) => t.toJson()).toList());
    await (await _prefs).setString(_chaveTransacoes, texto);
  }

  // ---------- Contas agendadas ----------

  Future<List<ContaAgendada>?> lerAgenda() async {
    final texto = (await _prefs).getString(_chaveAgenda);
    if (texto == null) return null;
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((e) => ContaAgendada.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> salvarAgenda(List<ContaAgendada> contas) async {
    final texto = jsonEncode(contas.map((c) => c.toJson()).toList());
    await (await _prefs).setString(_chaveAgenda, texto);
  }

  // ---------- Perfil ----------

  Future<Map<String, String>?> lerPerfil() async {
    final texto = (await _prefs).getString(_chavePerfil);
    if (texto == null) return null;
    final mapa = jsonDecode(texto) as Map<String, dynamic>;
    return mapa.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> salvarPerfil(Map<String, String> perfil) async {
    await (await _prefs).setString(_chavePerfil, jsonEncode(perfil));
  }
}
