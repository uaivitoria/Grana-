// Tela 4 — Análises
// Responsável: Rafael Penna

import 'package:flutter/material.dart';

import '../data/dados_fake.dart';
import '../theme/app_theme.dart';
import '../widgets/resumo_card.dart';

class AnalisesScreen extends StatefulWidget {
  const AnalisesScreen({super.key});

  @override
  State<AnalisesScreen> createState() => _AnalisesScreenState();
}

class _AnalisesScreenState extends State<AnalisesScreen> {
  String _periodo = 'Trimestre';

  @override
  Widget build(BuildContext context) {
    final dados = resumoPorPeriodo[_periodo]!;
    final receitas = dados.fold<double>(0, (s, d) => s + d.receita);
    final despesas = dados.fold<double>(0, (s, d) => s + d.despesa);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Análises',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Entradas x saídas por período',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final p in resumoPorPeriodo.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p),
                      selected: _periodo == p,
                      onSelected: (_) => setState(() => _periodo = p),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ResumoCard(
            rotulo: 'Receitas',
            valor: formatarReais(receitas),
            icone: Icons.trending_up,
            cor: AppColors.success,
          ),
          const SizedBox(height: 12),
          ResumoCard(
            rotulo: 'Despesas',
            valor: formatarReais(despesas),
            icone: Icons.trending_down,
            cor: AppColors.error,
          ),
          const SizedBox(height: 12),
          ResumoCard(
            rotulo: 'Saldo',
            valor: formatarReais(receitas - despesas),
            icone: Icons.attach_money,
            cor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Evolução financeira',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _GraficoBarras(dados: dados),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      _Legenda(cor: AppColors.success, texto: 'Receita'),
                      SizedBox(width: 16),
                      _Legenda(cor: AppColors.error, texto: 'Despesa'),
                    ],
                  ),
                ],
              ),
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
                    'Despesas por categoria',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  for (final g in gastosPorCategoria) _barraCategoria(g),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraCategoria(GastoCategoria g) {
    final total = gastosPorCategoria.fold<double>(0, (s, c) => s + c.valor);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Legenda(cor: g.cor, texto: g.nome),
              const Spacer(),
              Text(
                formatarReais(g.valor),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: g.valor / total,
              minHeight: 8,
              color: g.cor,
              backgroundColor: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gráfico de barras simples feito só com Containers (sem pacote externo).
class _GraficoBarras extends StatelessWidget {
  final List<ResumoMes> dados;
  const _GraficoBarras({required this.dados});

  @override
  Widget build(BuildContext context) {
    const alturaMax = 160.0;
    final maior = dados
        .expand((d) => [d.receita, d.despesa])
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: alturaMax + 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in dados)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _barra(d.receita / maior * alturaMax, AppColors.success),
                      const SizedBox(width: 4),
                      _barra(d.despesa / maior * alturaMax, AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.mes,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _barra(double altura, Color cor) {
    return Container(
      width: 12,
      height: altura < 2 ? 2 : altura,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String texto;
  const _Legenda({required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
