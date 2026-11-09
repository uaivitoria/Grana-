// Carteira: contas bancárias e cartões de crédito (aberta pelo Perfil)
// Responsável: Theo Purcino

import 'package:flutter/material.dart';

import '../data/dados_fake.dart';
import '../theme/app_theme.dart';
import 'cartao_detalhe_screen.dart';

class CarteiraScreen extends StatelessWidget {
  const CarteiraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carteira')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Minhas contas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final conta in contasBancarias)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: conta.cor,
                  child: Text(
                    conta.banco[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  conta.banco,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(conta.tipo),
                trailing: Text(
                  formatarReais(conta.saldo),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Cartões de crédito',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartoes.length,
            itemBuilder: (context, i) => _CartaoItem(cartao: cartoes[i]),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cadastro de conta/cartão na próxima etapa.'),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar conta ou cartão'),
          ),
        ],
      ),
    );
  }
}

class _CartaoItem extends StatelessWidget {
  final CartaoCredito cartao;
  const _CartaoItem({required this.cartao});

  @override
  Widget build(BuildContext context) {
    final ativo = cartao.status == 'Ativo';
    final statusCor = ativo ? AppColors.success : AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CartaoDetalheScreen(cartao: cartao),
            ),
          );
        },
        child: Column(
          children: [
            Container(height: 6, color: cartao.cor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        cartao.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusCor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          cartao.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusCor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.mutedForeground,
                      ),
                    ],
                  ),
                  Text(
                    '•••• ${cartao.finalNumero} · ${cartao.bandeira}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  BarraLimite(usado: cartao.usado, limite: cartao.limite),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _valor('Fatura', formatarReais(cartao.usado),
                          AppColors.error),
                      _valor('Disponível', formatarReais(cartao.disponivel),
                          AppColors.success),
                      _valor('Vence dia', '${cartao.vencimento}',
                          AppColors.foreground),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valor(String rotulo, String valor, Color cor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de uso do limite: verde até 60%, amarela até 80%, vermelha acima.
class BarraLimite extends StatelessWidget {
  final double usado;
  final double limite;

  const BarraLimite({super.key, required this.usado, required this.limite});

  @override
  Widget build(BuildContext context) {
    final pct = (usado / limite).clamp(0.0, 1.0);
    final cor = pct > 0.8
        ? AppColors.error
        : pct > 0.6
            ? AppColors.warning
            : AppColors.success;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: pct,
        minHeight: 8,
        color: cor,
        backgroundColor: AppColors.muted,
      ),
    );
  }
}
