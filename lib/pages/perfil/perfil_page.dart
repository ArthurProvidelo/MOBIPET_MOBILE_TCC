import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_card.dart';
import '../auth/login_page.dart';
import 'alterar_senha_page.dart';
import 'editar_perfil_page.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AppState>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: usuario?.avatarUrl != null ? NetworkImage(usuario!.avatarUrl!) : null,
                  child: usuario?.avatarUrl == null ? const Icon(Icons.person, size: 36) : null,
                ),
                const SizedBox(height: 12),
                Text(usuario?.nome ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text(usuario?.email ?? '', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, color: AppColors.primary),
                  title: const Text('Editar dados pessoais'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditarPerfilPage())),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                  title: const Text('Alterar minha senha'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlterarSenhaPage())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Sair do Aplicativo', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
              onTap: () async {
                final confirmar = await showConfirmDialog(
                  context,
                  title: 'Sair da conta?',
                  message: 'Você precisará entrar novamente para acompanhar seus pets.',
                  confirmLabel: 'Sair',
                  danger: true,
                );
                if (!context.mounted || !confirmar) return;
                await context.read<AppState>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
