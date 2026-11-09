import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/agenda_provider.dart';
import 'providers/cotacoes_provider.dart';
import 'providers/perfil_provider.dart';
import 'providers/sessao_provider.dart';
import 'providers/transacoes_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/cotacao_service.dart';
import 'services/cotemig_service.dart';
import 'services/storage_service.dart';
import 'services/viacep_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GranaMaisApp());
}

class GranaMaisApp extends StatelessWidget {
  /// Os serviços podem ser trocados nos testes (ex.: http falso).
  final StorageService? storage;
  final CotacaoService? cotacaoService;
  final ViaCepService? viaCepService;
  final CotemigService? cotemigService;

  const GranaMaisApp({
    super.key,
    this.storage,
    this.cotacaoService,
    this.viaCepService,
    this.cotemigService,
  });

  @override
  Widget build(BuildContext context) {
    final storage = this.storage ?? StorageService();

    // Telas -> Providers (estado) -> Services (HTTP e SharedPreferences).
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SessaoProvider(
            storage,
            cotemigService ?? CotemigService(),
          )..carregar(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransacoesProvider(storage)..carregar(),
        ),
        ChangeNotifierProvider(
          create: (_) => AgendaProvider(storage)..carregar(),
        ),
        ChangeNotifierProvider(
          create: (_) => PerfilProvider(
            storage,
            viaCepService ?? ViaCepService(),
          )..carregar(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CotacoesProvider(cotacaoService ?? CotacaoService())..carregar(),
        ),
      ],
      child: MaterialApp(
        title: 'Grana+',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const PortaDeEntrada(),
        builder: (context, child) => MolduraCelular(child: child!),
      ),
    );
  }
}

/// Decide a primeira tela: se já tem usuário salvo, vai direto ao Início.
class PortaDeEntrada extends StatelessWidget {
  const PortaDeEntrada({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessaoProvider>();
    if (!sessao.carregado) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return sessao.logado ? const MainShell() : const LoginScreen();
  }
}

/// Em telas largas (navegador no PC), mostra o app no tamanho de um celular.
/// No celular de verdade, ocupa a tela toda normalmente.
class MolduraCelular extends StatelessWidget {
  final Widget child;

  const MolduraCelular({super.key, required this.child});

  static const _largura = 400.0;
  static const _altura = 820.0;

  @override
  Widget build(BuildContext context) {
    final tela = MediaQuery.of(context).size;
    if (tela.width < 600) return child;

    final altura = tela.height - 40 < _altura ? tela.height - 40 : _altura;
    return ColoredBox(
      color: const Color(0xFF1C1F28),
      child: Center(
        child: Container(
          width: _largura,
          height: altura,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.black, width: 8),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(_largura - 16, altura - 16),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
