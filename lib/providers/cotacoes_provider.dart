import 'package:flutter/foundation.dart';

import '../data/dados_fake.dart';
import '../services/cotacao_service.dart';

enum EstadoCarga { carregando, sucesso, erro }

/// Cotações das moedas (API REST). Expõe o estado para a UI mostrar
/// loading, erro (com "Tentar de novo") ou os valores.
class CotacoesProvider extends ChangeNotifier {
  final CotacaoService _service;

  CotacoesProvider(this._service);

  EstadoCarga _estado = EstadoCarga.carregando;
  Map<String, Cotacao> _cotacoes = {};
  String? _erro;

  EstadoCarga get estado => _estado;
  Map<String, Cotacao> get cotacoes => Map.unmodifiable(_cotacoes);
  String? get erro => _erro;

  /// Moedas exibidas no card do Início, na ordem.
  static const destaques = ['USD', 'EUR', 'GBP'];

  Future<void> carregar() async {
    _estado = EstadoCarga.carregando;
    _erro = null;
    notifyListeners();
    try {
      final codigos = moedas
          .where((m) => m.codigo != 'BRL')
          .map((m) => m.codigo)
          .toList();
      _cotacoes = await _service.buscar(codigos);
      _estado = EstadoCarga.sucesso;
    } catch (e) {
      _erro = 'Não foi possível buscar as cotações. '
          'Verifique sua internet e tente de novo.';
      _estado = EstadoCarga.erro;
    }
    notifyListeners();
  }

  /// Quanto vale 1 unidade da moeda em reais.
  /// Usa a cotação da API; se ela falhou, usa a taxa de referência fixa.
  double valorEmReais(Moeda moeda) {
    if (moeda.codigo == 'BRL') return 1;
    return _cotacoes[moeda.codigo]?.valor ?? moeda.cotacaoEmReais;
  }

  bool temCotacaoAoVivo(String codigo) => _cotacoes.containsKey(codigo);
}
