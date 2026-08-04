import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/appointment.dart';
import '../../services/appointment_repository.dart';
import '../../services/auth_service.dart';
import '../../services/pet_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_card.dart';
import '../home/main_shell.dart';

/// Perfil do tutor com acesso às configurações da conta.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifications = true;
  bool _rfidAlerts = true;

  Future<void> _logout() async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Sair da conta?',
      message: 'Você precisará entrar novamente para acompanhar seus pets.',
      confirmLabel: 'Sair',
      destructive: true,
      icon: Icons.logout_rounded,
    );
    if (!confirmed || !mounted) return;
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (Route<dynamic> route) => false);
  }

  Future<void> _open(String route) async {
    final Object? result = await Navigator.of(context).pushNamed(route);
    if (!mounted || result is! String) return;
    AppFeedback.success(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.watch<AuthService>().currentUser;
    final int petCount = context.watch<PetRepository>().pets.length;
    final AppointmentRepository appointments = context
        .watch<AppointmentRepository>();
    final int completed = appointments.all
        .where((Appointment a) => a.status == AppointmentStatus.completed)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: <Widget>[
            _ProfileHeader(user: user),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _StatCard(
                  icon: Icons.pets_rounded,
                  value: '$petCount',
                  label: 'Pets',
                  onTap: () => MainShell.goToTab(context, 1),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.event_available_rounded,
                  value: '${appointments.upcoming.length}',
                  label: 'Ativos',
                  onTap: () => MainShell.goToTab(context, 2),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.verified_rounded,
                  value: '$completed',
                  label: 'Concluídos',
                  onTap: () => MainShell.goToTab(context, 2),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _MenuGroup(
              title: 'Conta',
              children: <Widget>[
                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Editar perfil',
                  description: 'Nome, e-mail, telefone e endereço',
                  onTap: () => _open(AppRoutes.editProfile),
                ),
                _MenuTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Alterar senha',
                  description: 'Atualize sua senha de acesso',
                  onTap: () => _open(AppRoutes.changePassword),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _MenuGroup(
              title: 'Preferências',
              children: <Widget>[
                _SwitchTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notificações push',
                  description: 'Avisos de agendamentos e lembretes',
                  value: _notifications,
                  onChanged: (bool value) {
                    setState(() => _notifications = value);
                    AppFeedback.info(
                      context,
                      value
                          ? 'Notificações ativadas.'
                          : 'Notificações desativadas.',
                    );
                  },
                ),
                _SwitchTile(
                  icon: Icons.nfc_rounded,
                  label: 'Alertas de etapa (RFID)',
                  description: 'Receber aviso a cada leitura do cartão',
                  value: _rfidAlerts,
                  onChanged: (bool value) {
                    setState(() => _rfidAlerts = value);
                    AppFeedback.info(
                      context,
                      value
                          ? 'Você será avisado a cada etapa concluída.'
                          : 'Alertas de etapa desativados.',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            _MenuGroup(
              title: 'Sobre',
              children: <Widget>[
                _MenuTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Ajuda e suporte',
                  description: 'Fale com a equipe do pet shop',
                  onTap: () => AppFeedback.info(
                    context,
                    'Suporte: (11) 4002-8922 · contato@mobipet.com.br',
                  ),
                ),
                _MenuTile(
                  icon: Icons.info_outline_rounded,
                  label: 'Sobre o MOBIPET',
                  description: 'Versão 1.0.0 · protótipo acadêmico',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'MOBIPET Monitoramento',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(
                      Icons.pets_rounded,
                      color: AppColors.blue,
                      size: 34,
                    ),
                    children: <Widget>[
                      const Text(
                        'Aplicativo de acompanhamento de atendimentos de pet '
                        'shop com etapas registradas por cartão RFID lido por '
                        'um ESP32. Protótipo com dados mockados, preparado '
                        'para integração com API Laravel.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger, width: 1.3),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'MOBIPET Monitoramento · v1.0.0',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.26),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                user?.initials ?? '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user?.name ?? 'Tutor',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (user?.memberSince != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Cliente desde ${Formatters.dateShort(user!.memberSince!)} '
                      'de ${user!.memberSince!.year}',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: <Widget>[
            Icon(icon, color: AppColors.blue, size: 22),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: AppColors.blue),
      ),
      title: Text(label, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(description, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.blue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      secondary: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: AppColors.blue),
      ),
      title: Text(label, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(description, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
