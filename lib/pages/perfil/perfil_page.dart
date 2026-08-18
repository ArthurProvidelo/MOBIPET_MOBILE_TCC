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
    final usuario = context.watch<AppState>().usuario;

    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.background,
                    child: Icon(Icons.person_outline_rounded, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  Text(usuario.nome, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(usuario.email, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 28),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Editar perfil',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditarPerfilPage()),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Alterar senha',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AlterarSenhaPage()),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(icon: Icons.phone_outlined, label: 'Telefone', trailing: usuario.telefone),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomCard(
              padding: EdgeInsets.zero,
              child: _ProfileTile(
                icon: Icons.logout_rounded,
                label: 'Sair da conta',
                iconColor: AppColors.danger,
                labelColor: AppColors.danger,
                onTap: () async {
                  final confirmar = await ConfirmDialog.show(
                    context,
                    title: 'Sair da conta',
                    message: 'Tem certeza que deseja sair?',
                    confirmLabel: 'Sair',
                    destructive: true,
                  );
                  if (!context.mounted || !confirmar) return;
                  context.read<AppState>().logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _ProfileTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(label, style: TextStyle(color: labelColor ?? AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: trailing != null
          ? Text(trailing!, style: const TextStyle(color: AppColors.textSecondary))
          : (onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary) : null),
    );
  }
}
