import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cotacoes_provider.dart';
import '../theme/app_theme.dart';

/// Card "Cotações do dia" do Início: mostra loading, erro com botão de
/// tentar de novo, ou as cotações vindas da AwesomeAPI.
class CotacoesCard extends StatelessWidget {
  const CotacoesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CotacoesProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.currency_exchange,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Cotações do dia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Atualizar cotações',
                  visualDensity: VisualDensity.compact,
                  onPressed: provider.estado == EstadoCarga.carregando
                      ? null
                      : provider.carregar,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            switch (provider.estado) {
              EstadoCarga.carregando => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Buscando cotações…'),
                    ],
                  ),
                ),
              EstadoCarga.erro => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.cloud_off, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.erro ?? 'Erro ao buscar cotações.',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: provider.carregar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              EstadoCarga.sucesso => Column(
                  children: [
                    for (final codigo in CotacoesProvider.destaques)
                      if (provider.cotacoes[codigo] != null)
                        _linha(
                          codigo,
                          provider.cotacoes[codigo]!.valor,
                          provider.cotacoes[codigo]!.variacao,
                        ),
                    if (provider.cotacoes.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Fonte: AwesomeAPI · '
                            '${provider.cotacoes.values.first.atualizadaEm}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }

  Widget _linha(String codigo, double valor, double variacao) {
    final subiu = variacao >= 0;
    final cor = subiu ? AppColors.success : AppColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              codigo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(formatarReais(valor))),
          Icon(subiu ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: cor),
          Text(
            '${variacao.abs().toStringAsFixed(2).replaceAll('.', ',')}%',
            style: TextStyle(color: cor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
