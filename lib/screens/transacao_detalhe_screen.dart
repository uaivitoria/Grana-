// Detalhe de uma movimentação (aberta pela lista do Início ou do cartão)
// Responsável: Sofia Purcino

import 'package:flutter/material.dart';

import '../data/dados_fake.dart';
import '../theme/app_theme.dart';

class TransacaoDetalheScreen extends StatelessWidget {
  final Transacao transacao;

  const TransacaoDetalheScreen({super.key, required this.transacao});

  @override
  Widget build(BuildContext context) {
    final t = transacao;
    final cor = t.isEntrada ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da movimentação')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(t.icone, color: cor, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              t.titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${t.isEntrada ? '+' : '-'} ${formatarReais(t.valor.abs())}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                _linha(Icons.swap_vert, 'Tipo',
                    t.isEntrada ? 'Entrada' : 'Saída'),
                _linha(Icons.category_outlined, 'Categoria', t.categoria),
                _linha(Icons.event, 'Data', t.data),
                _linha(Icons.payments_outlined, 'Forma de pagamento',
                    t.formaPagamento),
                if (t.cartao != null)
                  _linha(Icons.credit_card, 'Cartão', t.cartao!),
                _linha(Icons.currency_exchange, 'Moeda', 'BRL — Real'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edição na próxima etapa.')),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar movimentação'),
          ),
        ],
      ),
    );
  }

  Widget _linha(IconData icone, String rotulo, String valor) {
    return ListTile(
      leading: Icon(icone, color: AppColors.mutedForeground),
      title: Text(
        rotulo,
        style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
      ),
      trailing: Text(
        valor,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}
