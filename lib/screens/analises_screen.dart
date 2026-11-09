// Tela 4 — Análises (em breve)
// Responsável: Rafael Penna

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnalisesScreen extends StatelessWidget {
  /// Chamado pelo botão "Voltar ao início" (troca a aba no menu inferior).
  final VoidCallback onVoltarInicio;

  const AnalisesScreen({super.key, required this.onVoltarInicio});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 12),
                        SizedBox(width: 6),
                        Text(
                          'Em breve',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Uma nova visão da sua grana',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Estamos preparando suas análises financeiras: gráficos de '
                    'entradas x saídas por mês, trimestre, semestre e ano. '
                    'Por enquanto, acompanhe seus saldos e movimentações no '
                    'início.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.5,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: onVoltarInicio,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar ao início'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
