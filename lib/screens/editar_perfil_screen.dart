// Editar perfil: dados pessoais, endereço (CEP via ViaCEP) e moeda padrão
// Responsável: Daniel Augusto Gonçalves

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dados_fake.dart';
import '../providers/perfil_provider.dart';
import '../theme/app_theme.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _email;
  late final TextEditingController _telefone;
  late final TextEditingController _cep;
  late final TextEditingController _endereco;
  late String _moeda;

  bool _buscandoCep = false;
  String? _erroCep;

  @override
  void initState() {
    super.initState();
    final perfil = context.read<PerfilProvider>();
    _nome = TextEditingController(text: perfil.nome);
    _email = TextEditingController(text: perfil.email);
    _telefone = TextEditingController(text: perfil.telefone);
    _cep = TextEditingController(text: perfil.cep);
    _endereco = TextEditingController(text: perfil.endereco);
    _moeda = perfil.moeda;
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    _cep.dispose();
    _endereco.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    setState(() {
      _buscandoCep = true;
      _erroCep = null;
    });
    try {
      final endereco =
          await context.read<PerfilProvider>().buscarCep(_cep.text);
      _endereco.text = endereco.resumo;
    } catch (e) {
      _erroCep = e.toString().replaceFirst('Exception: ', '');
      if (_erroCep!.contains('TimeoutException') ||
          _erroCep!.contains('ClientException') ||
          _erroCep!.contains('SocketException')) {
        _erroCep = 'Sem conexão com o ViaCEP. Tente de novo.';
      }
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<PerfilProvider>().salvar(
          nome: _nome.text.trim(),
          email: _email.text.trim(),
          telefone: _telefone.text.trim(),
          cep: _cep.text.trim(),
          endereco: _endereco.text.trim(),
          moeda: _moeda,
        );
    messenger.showSnackBar(
      const SnackBar(content: Text('Perfil salvo.')),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (texto) => (texto == null || texto.trim().isEmpty)
                  ? 'Informe seu nome.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: (texto) {
                if (texto == null || texto.trim().isEmpty) {
                  return 'Informe seu e-mail.';
                }
                if (!texto.contains('@') || !texto.contains('.')) {
                  return 'E-mail inválido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Endereço',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cep,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) => _buscarCep(),
              decoration: InputDecoration(
                labelText: 'CEP',
                hintText: '00000-000',
                helperText: 'Toque na lupa para preencher o endereço.',
                errorText: _erroCep,
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: _buscandoCep
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Buscar CEP',
                        icon: const Icon(Icons.search,
                            color: AppColors.primary),
                        onPressed: _buscarCep,
                      ),
              ),
              validator: (texto) {
                final digitos = (texto ?? '').replaceAll(RegExp(r'\D'), '');
                if (digitos.length != 8) return 'O CEP deve ter 8 números.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _endereco,
              decoration: const InputDecoration(
                labelText: 'Rua, número, bairro e cidade',
                prefixIcon: Icon(Icons.home_outlined),
              ),
              validator: (texto) => (texto == null || texto.trim().isEmpty)
                  ? 'Informe o endereço.'
                  : null,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _moeda,
              decoration: const InputDecoration(
                labelText: 'Moeda padrão',
                prefixIcon: Icon(Icons.public),
              ),
              items: [
                for (final m in moedas)
                  DropdownMenuItem(
                    value: m.codigo,
                    child: Text('${m.codigo} — ${m.nome}'),
                  ),
              ],
              onChanged: (m) => setState(() => _moeda = m!),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.check),
              label: const Text('Salvar alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
