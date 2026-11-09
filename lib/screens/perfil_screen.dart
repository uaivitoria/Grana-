// Tela 6 — Perfil
// Responsável: Vitória Campos

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dados_fake.dart';
import '../providers/perfil_provider.dart';
import '../providers/sessao_provider.dart';
import '../theme/app_theme.dart';
import 'carteira_screen.dart';
import 'editar_perfil_screen.dart';
import 'login_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilProvider>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'DO SEU JEITO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: AppColors.primary,
            ),
          ),
          const Text(
            'Meu perfil',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Seus dados e preferências, em um só lugar.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  height: 72,
                  color: AppColors.primary.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: const Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'MINHA CONTA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          perfil.iniciais,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              perfil.nome,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Mais organização para conquistar seus planos.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.outlined(
                        tooltip: 'Editar perfil',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditarPerfilScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                _info(Icons.mail_outline, 'E-mail', perfil.email),
                _info(Icons.phone_outlined, 'Telefone', perfil.telefone),
                _info(Icons.location_on_outlined, 'Endereço',
                    '${perfil.endereco}\nCEP ${perfil.cep}'),
                _info(Icons.public, 'Moeda padrão', perfil.moedaDescricao),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined),
              ),
              title: const Text(
                'Carteira',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${contasBancarias.length} contas · ${cartoes.length} cartões',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CarteiraScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              // Apaga o usuário salvo: ao reabrir, o app pede login de novo.
              await context.read<SessaoProvider>().sair();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (rota) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Grana + · Mais clareza para sua vida financeira.',
              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icone, String rotulo, String valor) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icone, size: 20, color: AppColors.mutedForeground),
      ),
      title: Text(
        rotulo,
        style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
      ),
      subtitle: Text(
        valor,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}
