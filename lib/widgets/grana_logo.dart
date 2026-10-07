import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logo "G+ Grana +" usado no login e no topo do app.
class GranaLogo extends StatelessWidget {
  final double tamanho;

  const GranaLogo({super.key, this.tamanho = 48});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: tamanho,
          height: tamanho,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(tamanho / 4),
          ),
          child: Text(
            'G+',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: tamanho * 0.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text.rich(
          TextSpan(
            text: 'Grana ',
            children: const [
              TextSpan(text: '+', style: TextStyle(color: AppColors.primary)),
            ],
          ),
          style: TextStyle(
            fontSize: tamanho * 0.5,
            fontWeight: FontWeight.bold,
            color: AppColors.foreground,
          ),
        ),
      ],
    );
  }
}
