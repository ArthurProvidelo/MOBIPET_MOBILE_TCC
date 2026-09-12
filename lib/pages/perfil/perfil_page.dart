import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/app_page_route.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_card.dart';
import '../auth/login_page.dart';
import 'alterar_senha_page.dart';
import 'editar_perfil_page.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final usuario = appState.usuario;
    final foto = appState.fotoPerfil;

    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              title: const Text('Perfil'),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              titleTextStyle: Theme.of(context).textTheme.headlineLarge,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList.list(
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.background,
                          backgroundImage: foto != null ? FileImage(foto) : null,
                          child: foto == null
                              ? Icon(Icons.person_outline_rounded,
                                  size: 40, color: AppColors.primary)
                              : null,
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
                            AppPageRoute.modal((_) => const EditarPerfilPage()),
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _ProfileTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Alterar senha',
                          onTap: () => Navigator.of(context).push(
                            AppPageRoute.modal((_) => const AlterarSenhaPage()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.badge_outlined,
                          label: 'CPF',
                          trailing: Mascaras.cpf(usuario.cpf),
                        ),
                        const Divider(height: 1, indent: 56),
                        _ProfileTile(
                          icon: Icons.phone_outlined,
                          label: 'Telefone',
                          trailing: Mascaras.telefone(usuario.telefone),
                        ),
                        const Divider(height: 1, indent: 56),
                        _ProfileTile(
                          icon: Icons.location_on_outlined,
                          label: 'CEP',
                          trailing: Mascaras.cep(usuario.cep),
                        ),
                        const Divider(height: 1, indent: 56),
                        _ProfileTile(
                          icon: Icons.home_outlined,
                          label: 'Endereço',
                          valor: usuario.endereco.isEmpty ? '—' : usuario.endereco,
                        ),
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
                          AppPageRoute.fade((_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
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

  /// Valor curto exibido à direita (CPF, telefone, CEP).
  final String? trailing;

  /// Valor possivelmente longo, exibido abaixo do rótulo (endereço).
  final String? valor;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _ProfileTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.valor,
    this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: valor != null
          ? Text(valor!, style: TextStyle(color: AppColors.textSecondary))
          : null,
      trailing: trailing != null
          ? Text(trailing!, style: TextStyle(color: AppColors.textSecondary))
          : (onTap != null
              ? Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary)
              : null),
    );
  }
}
