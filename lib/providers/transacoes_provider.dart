import 'package:flutter/foundation.dart';

import '../data/dados_fake.dart';
import '../services/storage_service.dart';

/// Lista de lançamentos (entradas e saídas) + totais do Início.
/// Cada alteração é salva no SharedPreferences pelo StorageService.
class TransacoesProvider extends ChangeNotifier {
  final StorageService _storage;

  TransacoesProvider(this._storage);

  /// Saldo das contas antes dos lançamentos da lista, calculado para que,
  /// na primeira abertura, o saldo mostrado seja o mesmo do protótipo.
  static final double _saldoBase =
      saldoTotal - transacoesRecentes.fold(0.0, (s, t) => s + t.valor);

  List<Transacao> _transacoes = [];
  bool _carregando = true;
  String? _erro;

  List<Transacao> get transacoes => List.unmodifiable(_transacoes);
  bool get carregando => _carregando;
  String? get erro => _erro;

  double get entradas =>
      _transacoes.where((t) => t.isEntrada).fold(0.0, (s, t) => s + t.valor);

  double get saidas => _transacoes
      .where((t) => !t.isEntrada)
      .fold(0.0, (s, t) => s + t.valor.abs());

  double get gastosCartao => _transacoes
      .where((t) => !t.isEntrada && t.formaPagamento == 'Crédito')
      .fold(0.0, (s, t) => s + t.valor.abs());

  double get saldo => _saldoBase + entradas - saidas;

  bool contem(Transacao t) => _transacoes.contains(t);

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final salvas = await _storage.lerTransacoes();
      // Primeira abertura: começa com os exemplos.
      _transacoes = salvas ?? List.of(transacoesRecentes);
    } catch (e) {
      _erro = 'Não foi possível ler seus lançamentos.';
      _transacoes = List.of(transacoesRecentes);
    }
    _carregando = false;
    notifyListeners();
  }

  Future<void> adicionar(Transacao t) async {
    _transacoes.insert(0, t); // mais recente primeiro
    notifyListeners();
    await _storage.salvarTransacoes(_transacoes);
  }

  Future<void> remover(Transacao t) async {
    _transacoes.remove(t);
    notifyListeners();
    await _storage.salvarTransacoes(_transacoes);
  }
}
