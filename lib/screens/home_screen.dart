// Tela 2 — Início (Home)
// Responsável: Sofia Purcino

import 'package:flutter/material.dart';

import '../data/dados_fake.dart';
import '../theme/app_theme.dart';
import '../widgets/resumo_card.dart';
import 'transacao_detalhe_screen.dart';

const _meses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho',
  'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mês exibido no card de saldo (só troca o rótulo; os dados são fixos).
  int _mes = 9; // Outubro
  int _ano = 2026;

  void _mesAnterior() {
    setState(() {
      if (_mes == 0) {
        _mes = 11;
        _ano--;
      } else {
        _mes--;
      }
    });
  }

  void _proximoMes() {
    setState(() {
      if (_mes == 11) {
        _mes = 0;
        _ano++;
      } else {
        _mes++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Olá, $nomeUsuario',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Veja como estão suas finanças.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),
          _cardSaldo(),
          const SizedBox(height: 12),
          ResumoCard(
            rotulo: 'Entradas',
            valor: formatarReais(entradasMes),
            icone: Icons.arrow_upward,
            cor: AppColors.success,
          ),
          const SizedBox(height: 12),
          ResumoCard(
            rotulo: 'Saídas',
            valor: formatarReais(saidasMes),
            icone: Icons.arrow_downward,
            cor: AppColors.error,
          ),
          const SizedBox(height: 12),
          ResumoCard(
            rotulo: 'Cartão',
            valor: formatarReais(cartaoMes),
            icone: Icons.credit_card,
            cor: AppColors.foreground,
          ),
          const SizedBox(height: 24),
          const Text(
            'Últimas movimentações',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transacoesRecentes.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, i) {
                final t = transacoesRecentes[i];
                final cor = t.isEntrada ? AppColors.success : AppColors.primary;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cor.withValues(alpha: 0.12),
                    child: Icon(t.icone, color: cor, size: 20),
                  ),
                  title: Text(
                    t.titulo,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${t.categoria} · ${t.data}'),
                  trailing: Text(
                    '${t.isEntrada ? '+' : '-'} ${formatarReais(t.valor.abs())}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: t.isEntrada
                          ? AppColors.success
                          : AppColors.foreground,
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
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _cardSaldo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'SALDO TOTAL',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Mês anterior',
                      onPressed: _mesAnterior,
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                    Text(
                      '${_meses[_mes]} $_ano',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Próximo mês',
                      onPressed: _proximoMes,
                      icon:
                          const Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatarReais(saldoTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  '$tendenciaMes este mês',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
