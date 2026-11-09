import 'package:flutter/foundation.dart';

import '../data/dados_fake.dart';
import '../services/storage_service.dart';

/// Contas a pagar/receber do Calendário. Persistidas no SharedPreferences.
class AgendaProvider extends ChangeNotifier {
  final StorageService _storage;

  AgendaProvider(this._storage);

  List<ContaAgendada> _contas = [];

  List<ContaAgendada> get contas => List.unmodifiable(_contas);

  List<ContaAgendada> doDia(int dia) =>
      _contas.where((c) => c.dia == dia).toList();

  Future<void> carregar() async {
    try {
      _contas = await _storage.lerAgenda() ?? List.of(contasAgendadas);
    } catch (_) {
      _contas = List.of(contasAgendadas);
    }
    _ordenar();
    notifyListeners();
  }

  Future<void> adicionar(ContaAgendada conta) async {
    _contas.add(conta);
    _ordenar();
    notifyListeners();
    await _storage.salvarAgenda(_contas);
  }

  void _ordenar() => _contas.sort((a, b) => a.dia.compareTo(b.dia));
}
