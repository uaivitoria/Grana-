// Agendar conta a pagar/receber (aberta pelo Calendário)
// Responsável: Rafael Penna

import 'package:flutter/material.dart';

class AgendarContaScreen extends StatefulWidget {
  const AgendarContaScreen({super.key});

  @override
  State<AgendarContaScreen> createState() => _AgendarContaScreenState();
}

class _AgendarContaScreenState extends State<AgendarContaScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'vencimento';

  void _agendar() {
    if (!_formKey.currentState!.validate()) return;
    // Etapa 2: não salva (SharedPreferences entra na próxima etapa).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conta agendada (fictício — salva na próxima etapa).'),
      ),
    );
    Navigator.pop(context);
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
