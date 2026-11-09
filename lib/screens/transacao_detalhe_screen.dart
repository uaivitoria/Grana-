// Detalhe de uma movimentação (aberta pela lista do Início ou do cartão)
// Responsável: Sofia Purcino

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dados_fake.dart';
import '../providers/transacoes_provider.dart';
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
                _linha(Icons.currency_exchange, 'Moeda', t.moeda),
                if (t.valorOriginal != null)
                  _linha(Icons.payments, 'Valor original',
                      '${t.moeda} ${t.valorOriginal!.toStringAsFixed(2).replaceAll('.', ',')}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Só lançamentos da lista do Início podem ser excluídos.
          if (context.watch<TransacoesProvider>().contem(t))
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => _confirmarExclusao(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir movimentação'),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Excluir movimentação?'),
        content: Text('"${transacao.titulo}" será removida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !context.mounted) return;
    final navigator = Navigator.of(context);
    await context.read<TransacoesProvider>().remover(transacao);
    navigator.pop();
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
