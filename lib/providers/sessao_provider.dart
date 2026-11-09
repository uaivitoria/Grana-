import 'package:flutter/foundation.dart';

import '../services/cotemig_service.dart';
import '../services/storage_service.dart';

/// Login com a API do Cotemig. A sessão (usuário, nome e token) fica salva:
/// ao reabrir o app, vai direto para o Início.
class SessaoProvider extends ChangeNotifier {
  final StorageService _storage;
  final CotemigService _cotemig;

  SessaoProvider(this._storage, this._cotemig);

  String? _usuario;
  String? _nome;
  String? _token;
  bool _carregado = false;
  bool _entrando = false;
  String? _erro;

  String? get usuario => _usuario;
  String? get nome => _nome;
  bool get carregado => _carregado;
  bool get logado => _token != null;
  bool get entrando => _entrando;
  String? get erro => _erro;

  /// Nome para a saudação: "MARIA DA SILVA" -> "Maria".
  String get primeiroNome {
    final base = (_nome?.isNotEmpty ?? false) ? _nome! : (_usuario ?? '');
    final primeiro = base.trim().split(RegExp(r'[ ._@-]')).first;
    if (primeiro.isEmpty) return base;
    return primeiro[0].toUpperCase() + primeiro.substring(1).toLowerCase();
  }

  Future<void> carregar() async {
    try {
      final sessao = await _storage.lerSessao();
      if (sessao != null && (sessao['token'] ?? '').isNotEmpty) {
        _usuario = sessao['usuario'];
        _nome = sessao['nome'];
        _token = sessao['token'];
      }
    } catch (_) {
      // Sessão corrompida: pede login de novo.
    }
    _carregado = true;
    notifyListeners();
  }

  /// Retorna o login se deu certo; se não, null e [erro] fica preenchido.
  Future<LoginCotemig?> entrar(String usuario, String senha) async {
    _entrando = true;
    _erro = null;
    notifyListeners();
    try {
      final login = await _cotemig.entrar(usuario.trim(), senha);
      _usuario = login.usuario;
      _nome = login.nome;
      _token = login.token;
      await _storage.salvarSessao(
        usuario: login.usuario,
        nome: login.nome,
        token: login.token,
      );
      return login;
    } on LoginException catch (e) {
      _erro = e.mensagem;
      return null;
    } catch (_) {
      _erro = 'Não foi possível entrar. Tente de novo.';
      return null;
    } finally {
      _entrando = false;
      notifyListeners();
    }
  }

  Future<void> sair() async {
    final token = _token;
    _usuario = null;
    _nome = null;
    _token = null;
    await _storage.apagarSessao();
    notifyListeners();
    if (token != null) await _cotemig.sair(token);
  }
}
