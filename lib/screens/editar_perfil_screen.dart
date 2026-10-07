// Editar perfil: dados pessoais, endereço (CEP) e moeda padrão
// Responsável: Daniel Augusto Gonçalves

import 'package:flutter/material.dart';

import '../data/dados_fake.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  String _moeda = 'BRL';

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    // Etapa 2: não salva nem consulta o ViaCEP.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil salvo (fictício — gravação na próxima etapa).'),
      ),
    );
    Navigator.pop(context);
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
              initialValue: perfilNome,
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
              initialValue: perfilEmail,
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
              initialValue: perfilTelefone,
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
              initialValue: perfilCep,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CEP',
                hintText: '00000-000',
                helperText: 'O preenchimento automático vem na próxima etapa.',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (texto) {
                final digitos = (texto ?? '').replaceAll(RegExp(r'\D'), '');
                if (digitos.length != 8) return 'O CEP deve ter 8 números.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: perfilEndereco,
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
