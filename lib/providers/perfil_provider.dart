import 'package:flutter/foundation.dart';

import '../data/dados_fake.dart';
import '../services/storage_service.dart';
import '../services/viacep_service.dart';

/// Dados do perfil (persistidos) + busca de endereço pelo CEP (ViaCEP).
class PerfilProvider extends ChangeNotifier {
  final StorageService _storage;
  final ViaCepService _viaCep;

  PerfilProvider(this._storage, this._viaCep);

  String nome = perfilNome;
  String email = perfilEmail;
  String telefone = perfilTelefone;
  String cep = perfilCep;
  String endereco = perfilEndereco;
  String moeda = 'BRL';

  String get iniciais {
    final partes =
        nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    final primeira = partes.first[0];
    final ultima = partes.length > 1 ? partes.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }

  String get moedaDescricao {
    final m = moedas.firstWhere(
      (m) => m.codigo == moeda,
      orElse: () => moedas.first,
    );
    return '${m.codigo} — ${m.nome}';
  }

  Future<void> carregar() async {
    try {
      final salvo = await _storage.lerPerfil();
      if (salvo != null) {
        nome = salvo['nome'] ?? nome;
        email = salvo['email'] ?? email;
        telefone = salvo['telefone'] ?? telefone;
        cep = salvo['cep'] ?? cep;
        endereco = salvo['endereco'] ?? endereco;
        moeda = salvo['moeda'] ?? moeda;
      }
    } catch (_) {
      // Mantém os valores padrão se o dado salvo estiver corrompido.
    }
    notifyListeners();
  }

  /// Depois do login no Cotemig: usa nome e e-mail do aluno no perfil.
  Future<void> preencherDoCotemig({
    required String nome,
    required String email,
  }) {
    return salvar(
      nome: nome.isEmpty ? this.nome : nome,
      email: email.isEmpty ? this.email : email,
      telefone: telefone,
      cep: cep,
      endereco: endereco,
      moeda: moeda,
    );
  }

  Future<void> salvar({
    required String nome,
    required String email,
    required String telefone,
    required String cep,
    required String endereco,
    required String moeda,
  }) async {
    this.nome = nome;
    this.email = email;
    this.telefone = telefone;
    this.cep = cep;
    this.endereco = endereco;
    this.moeda = moeda;
    notifyListeners();
    await _storage.salvarPerfil({
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cep': cep,
      'endereco': endereco,
      'moeda': moeda,
    });
  }

  /// Consulta o ViaCEP. Lança Exception com mensagem amigável se falhar.
  Future<EnderecoCep> buscarCep(String cep) => _viaCep.buscar(cep);
}
