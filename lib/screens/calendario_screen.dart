// Tela 5 — Calendário
// Responsável: Rafael Penna

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dados_fake.dart';
import '../providers/agenda_provider.dart';
import '../theme/app_theme.dart';
import 'agendar_conta_screen.dart';

const _diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

const _rotuloTipo = {
  'receita': 'Receita',
  'despesa': 'Despesa',
  'vencimento': 'Vencimento',
};

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  // Mostra o mês atual; as contas se repetem todo mês no mesmo dia.
  static const _nomesMeses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho',
    'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  final _hoje = DateTime.now();
  int get _ano => _hoje.year;
  int get _mes => _hoje.month;
  int? _diaSelecionado;

  List<ContaAgendada> _contas = [];

  List<ContaAgendada> _contasDoDia(int dia) =>
      _contas.where((c) => c.dia == dia).toList();

  @override
  Widget build(BuildContext context) {
    final contasAgendadas = context.watch<AgendaProvider>().contas;
    _contas = contasAgendadas;
    final diasNoMes = DateTime(_ano, _mes + 1, 0).day;
    final primeiroDiaSemana = DateTime(_ano, _mes, 1).weekday % 7; // 0 = Dom
    final contasSelecionadas =
        _diaSelecionado == null ? <ContaAgendada>[] : _contasDoDia(_diaSelecionado!);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calendário',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Receitas, despesas e vencimentos',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AgendarContaScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Agendar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            children: [
              for (final tipo in _rotuloTipo.keys)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ponto(coresTipoConta[tipo]!, 10),
                    const SizedBox(width: 6),
                    Text(
                      _rotuloTipo[tipo]!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${_nomesMeses[_mes - 1]} $_ano',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (final d in _diasSemana)
                        Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: primeiroDiaSemana + diasNoMes,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (context, i) {
                      if (i < primeiroDiaSemana) return const SizedBox();
                      final dia = i - primeiroDiaSemana + 1;
                      return _celulaDia(dia);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_diaSelecionado != null) ...[
            Text(
              'Dia $_diaSelecionado/$_mes',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (contasSelecionadas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Nenhuma conta neste dia.',
                  style: TextStyle(color: AppColors.mutedForeground),
                ),
              )
            else
              for (final c in contasSelecionadas) _itemConta(c),
          ] else ...[
            const Text(
              'Contas agendadas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            for (final c in contasAgendadas) _itemConta(c),
          ],
        ],
      ),
    );
  }

  Widget _celulaDia(int dia) {
    final contas = _contasDoDia(dia);
    final selecionado = _diaSelecionado == dia;
    final hoje = dia == _hoje.day;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() {
        _diaSelecionado = selecionado ? null : dia;
      }),
      child: Container(
        decoration: BoxDecoration(
          color: selecionado
              ? AppColors.primary
              : hoje
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dia',
              style: TextStyle(
                fontWeight: hoje ? FontWeight.bold : FontWeight.w500,
                color: selecionado
                    ? Colors.white
                    : hoje
                        ? AppColors.primary
                        : AppColors.foreground,
              ),
            ),
            if (contas.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final c in contas)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: _ponto(
                        selecionado ? Colors.white : coresTipoConta[c.tipo]!,
                        6,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _itemConta(ContaAgendada c) {
    final cor = coresTipoConta[c.tipo]!;
    final sinal = c.tipo == 'receita' ? '+' : '-';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _ponto(cor, 12),
        title: Text(c.descricao),
        subtitle: Text('${_rotuloTipo[c.tipo]} · dia ${c.dia}/$_mes'),
        trailing: Text(
          '$sinal ${formatarReais(c.valor)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: cor),
        ),
      ),
    );
  }

  Widget _ponto(Color cor, double tamanho) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
    );
  }
}
