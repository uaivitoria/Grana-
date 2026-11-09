// Tela 2 — Início (Home)
// Responsável: Sofia Purcino

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sessao_provider.dart';
import '../providers/transacoes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cotacoes_card.dart';
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
  // Mês exibido no card de saldo (só troca o rótulo).
  int _mes = DateTime.now().month - 1;
  int _ano = DateTime.now().year;

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
    final nome = context.watch<SessaoProvider>().primeiroNome;
    final dados = context.watch<TransacoesProvider>();
    final transacoes = dados.transacoes;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Olá, $nome',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Veja como estão suas finanças.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),
          _cardSaldo(dados.saldo),
          const SizedBox(height: 12),
          ResumoCard(
            rotulo: 'Entradas',
            valor: formatarReais(dados.entradas),
            icone: Icons.arrow_upward,
            cor: AppColors.success,
          ),
          const SizedBox(height: 12),
          ResumoCard(
            rotulo: 'Saídas',
            valor: formatarReais(dados.saidas),
            icone: Icons.arrow_downward,
            cor: AppColors.error,
          ),
          const SizedBox(height: 12),
          ResumoCard(
            rotulo: 'Cartão',
            valor: formatarReais(dados.gastosCartao),
            icone: Icons.credit_card,
            cor: AppColors.foreground,
          ),
          const SizedBox(height: 24),
          // Dados da API REST (AwesomeAPI) com loading e erro.
          const CotacoesCard(),
          const SizedBox(height: 24),
          const Text(
            'Últimas movimentações',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (dados.carregando)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (transacoes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhuma movimentação ainda. Toque no + para lançar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedForeground),
                ),
              ),
            )
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transacoes.length,
                itemBuilder: (context, i) {
                  final t = transacoes[i];
                  final cor =
                      t.isEntrada ? AppColors.success : AppColors.primary;
                  return Column(
                    children: [
                      if (i > 0)
                        const Divider(height: 1, color: AppColors.border),
                      ListTile(
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
                          '${t.isEntrada ? '+' : '-'} '
                          '${formatarReais(t.valor.abs())}',
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
                              builder: (_) =>
                                  TransacaoDetalheScreen(transacao: t),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _cardSaldo(double saldo) {
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
            formatarReais(saldo),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
