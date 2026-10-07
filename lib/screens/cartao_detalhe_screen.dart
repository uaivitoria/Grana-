// Detalhe do cartão de crédito (aberto pela Carteira)
// Responsável: Daniel Augusto Gonçalves

import 'package:flutter/material.dart';

import '../data/dados_fake.dart';
import '../theme/app_theme.dart';
import 'carteira_screen.dart';
import 'transacao_detalhe_screen.dart';

class CartaoDetalheScreen extends StatelessWidget {
  final CartaoCredito cartao;

  const CartaoDetalheScreen({super.key, required this.cartao});

  @override
  Widget build(BuildContext context) {
    final melhorDia = cartao.fechamento - 1 > 0 ? cartao.fechamento - 1 : 28;

    return Scaffold(
      appBar: AppBar(title: Text(cartao.nome)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Visual do cartão (bloco colorido, sem imagem de rede)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cartao.cor, cartao.cor.withValues(alpha: 0.6)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartao.banco.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            cartao.nome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cartao.bandeira.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '••••  ••••  ••••  ${cartao.finalNumero}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _infoCartao('Fechamento', 'Dia ${cartao.fechamento}'),
                    _infoCartao('Vencimento', 'Dia ${cartao.vencimento}'),
                    _infoCartao('Melhor compra', 'Após dia $melhorDia'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Limite do cartão',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  BarraLimite(usado: cartao.usado, limite: cartao.limite),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _valorLimite('Total', cartao.limite, AppColors.foreground),
                      _valorLimite('Utilizado', cartao.usado, AppColors.error),
                      _valorLimite(
                          'Disponível', cartao.disponivel, AppColors.success),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Transações deste cartão',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final t in cartao.transacoes)
                  ListTile(
                    leading: Icon(t.icone, color: AppColors.mutedForeground),
                    title: Text(t.titulo),
                    subtitle: Text('${t.categoria} · ${t.data}'),
                    trailing: Text(
                      formatarReais(t.valor),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransacaoDetalheScreen(transacao: t),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCartao(String rotulo, String valor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _valorLimite(String rotulo, double valor, Color cor) {
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
            formatarReais(valor),
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
