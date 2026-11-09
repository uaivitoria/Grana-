// Agendar conta a pagar/receber (aberta pelo Calendário)
// Responsável: Rafael Penna

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dados_fake.dart';
import '../providers/agenda_provider.dart';

class AgendarContaScreen extends StatefulWidget {
  const AgendarContaScreen({super.key});

  @override
  State<AgendarContaScreen> createState() => _AgendarContaScreenState();
}

class _AgendarContaScreenState extends State<AgendarContaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _diaController = TextEditingController();
  String _tipo = 'vencimento';

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _diaController.dispose();
    super.dispose();
  }

  Future<void> _agendar() async {
    if (!_formKey.currentState!.validate()) return;
    final conta = ContaAgendada(
      int.parse(_diaController.text.trim()),
      _descricaoController.text.trim(),
      double.parse(_valorController.text.trim().replaceAll(',', '.')),
      _tipo,
    );
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    // Provider adiciona e salva no SharedPreferences.
    await context.read<AgendaProvider>().adicionar(conta);
    messenger.showSnackBar(
      const SnackBar(content: Text('Conta agendada.')),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar conta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'vencimento', label: Text('A pagar')),
                ButtonSegment(value: 'receita', label: Text('A receber')),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex: Conta de luz',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (texto) => (texto == null || texto.trim().isEmpty)
                  ? 'Informe a descrição.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                hintText: '0,00',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (texto) {
                if (texto == null || texto.trim().isEmpty) {
                  return 'Informe o valor.';
                }
                final numero = double.tryParse(texto.replaceAll(',', '.'));
                if (numero == null || numero <= 0) {
                  return 'Digite um valor maior que zero.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Dia do mês',
                hintText: '1 a 31',
                prefixIcon: Icon(Icons.event),
              ),
              validator: (texto) {
                final dia = int.tryParse(texto ?? '');
                if (dia == null || dia < 1 || dia > 31) {
                  return 'Informe um dia entre 1 e 31.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: _agendar, child: const Text('Agendar')),
          ],
        ),
      ),
    );
  }
}
