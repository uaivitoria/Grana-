// Menu inferior do app (Início, Análises, Adicionar, Calendário, Perfil)
// Responsável: Vitória Campos

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'adicionar_screen.dart';
import 'analises_screen.dart';
import 'calendario_screen.dart';
import 'home_screen.dart';
import 'perfil_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _abaAtual = 0;

  void _abrirAdicionar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _abaAtual,
        children: [
          const HomeScreen(),
          AnalisesScreen(onVoltarInicio: () => setState(() => _abaAtual = 0)),
          const CalendarioScreen(),
          const PerfilScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirAdicionar,
        tooltip: 'Adicionar',
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.foreground,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.card,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _itemMenu(0, Icons.home_outlined, Icons.home, 'Início'),
            _itemMenu(
              1,
              Icons.bar_chart_outlined,
              Icons.bar_chart,
              'Análises',
              emBreve: true,
            ),
            const SizedBox(width: 72),
            _itemMenu(
              2,
              Icons.calendar_month_outlined,
              Icons.calendar_month,
              'Calendário',
            ),
            _itemMenu(3, Icons.person_outline, Icons.person, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _itemMenu(
    int indice,
    IconData icone,
    IconData iconeAtivo,
    String rotulo, {
    bool emBreve = false,
  }) {
    final ativo = _abaAtual == indice;
    final cor = ativo ? AppColors.primary : AppColors.mutedForeground;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _abaAtual = indice),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: emBreve,
              backgroundColor: AppColors.secondary,
              textColor: AppColors.foreground,
              label: const Text('breve', style: TextStyle(fontSize: 8)),
              child: Icon(ativo ? iconeAtivo : icone, color: cor),
            ),
            const SizedBox(height: 2),
            Text(
              rotulo,
              style: TextStyle(
                fontSize: 11,
                color: cor,
                fontWeight: ativo ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
