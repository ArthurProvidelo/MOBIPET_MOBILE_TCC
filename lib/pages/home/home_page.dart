import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/appointment.dart';
import '../../models/monitoring_session.dart';
import '../../models/pet.dart';
import '../../models/pet_service.dart';
import '../../models/service_stage.dart';
import '../../services/appointment_repository.dart';
import '../../services/auth_service.dart';
import '../../services/monitoring_service.dart';
import '../../services/pet_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/current_service_card.dart';
import '../../widgets/loading_placeholder.dart';
import '../../widgets/section_header.dart';
import '../../widgets/service_card.dart';
import '../../widgets/stage_timeline.dart';
import '../appointments/service_details_page.dart';
import 'main_shell.dart';

/// Tela inicial: saudação, atendimento atual, timeline resumida,
/// próximos agendamentos e catálogo de serviços.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await Future.wait(<Future<void>>[
      context.read<PetRepository>().refresh(),
      context.read<AppointmentRepository>().refresh(),
    ]);
    if (!mounted) return;
    setState(() => _refreshing = false);
    AppFeedback.info(context, 'Informações atualizadas.');
  }

  void _restartDemo() {
    context.read<MonitoringService>().restartDemo();
    AppFeedback.rfid(context, 'Novo atendimento demonstrativo iniciado.');
  }

  void _simulateRfid() {
    final MonitoringService monitoring = context.read<MonitoringService>();
    final ServiceStage? stage = monitoring.registerRfidRead();
    if (stage == null) {
      AppFeedback.info(context, 'O atendimento já foi finalizado.');
      return;
    }
    AppFeedback.rfid(
      context,
      'Cartão RFID lido: etapa "${stage.label}" registrada.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.watch<AuthService>().currentUser;
    final PetRepository pets = context.watch<PetRepository>();
    final AppointmentRepository appointments = context
        .watch<AppointmentRepository>();
    final MonitoringService monitoring = context.watch<MonitoringService>();
    final MonitoringSession? session = monitoring.session;
    final List<Appointment> upcoming = appointments.upcoming;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.blue,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: <Widget>[
              _Header(user: user),
              const SizedBox(height: 22),
              if (_refreshing)
                const LoadingList(itemCount: 2)
              else if (session != null) ...<Widget>[
                CurrentServiceCard(
                  session: session,
                  pet: pets.byId(session.petId),
                  service: appointments.serviceById(session.serviceId),
                  onTap: () => _openMonitoring(session),
                ),
                const SizedBox(height: 16),
                _TimelineSummary(
                  session: session,
                  onDetails: () => _openMonitoring(session),
                  onSimulate: _simulateRfid,
                ),
              ] else
                _NoServiceCard(
                  onSchedule: () =>
                      Navigator.of(context).pushNamed(AppRoutes.newAppointment),
                  onRestartDemo: _restartDemo,
                ),
              const SizedBox(height: 26),
              SectionHeader(
                title: 'Próximos agendamentos',
                subtitle: upcoming.isEmpty
                    ? 'Nenhum horário marcado'
                    : '${upcoming.length} agendamento(s) ativo(s)',
                actionLabel: upcoming.isEmpty ? null : 'Ver todos',
                onAction: upcoming.isEmpty
                    ? null
                    : () => MainShell.goToTab(context, 2),
              ),
              const SizedBox(height: 14),
              if (_refreshing)
                const LoadingList(itemCount: 2)
              else if (upcoming.isEmpty)
                _EmptyAppointments(
                  onSchedule: () =>
                      Navigator.of(context).pushNamed(AppRoutes.newAppointment),
                )
              else
                ...upcoming
                    .take(2)
                    .map(
                      (Appointment appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AppointmentCard(
                          appointment: appointment,
                          pet: pets.byId(appointment.petId),
                          service: appointments.serviceById(
                            appointment.serviceId,
                          ),
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.serviceDetails,
                            arguments: ServiceDetailsArgs(
                              serviceId: appointment.serviceId,
                              appointmentId: appointment.id,
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 12),
              const SectionHeader(
                title: 'Serviços do pet shop',
                subtitle: 'Toque para ver os detalhes e agendar',
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.35,
                children: appointments.services
                    .map(
                      (PetService service) => ServiceCard(
                        service: service,
                        dense: true,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.serviceDetails,
                          arguments: ServiceDetailsArgs(serviceId: service.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              _PetsStrip(pets: pets.pets),
            ],
          ),
        ),
      ),
    );
  }

  void _openMonitoring(MonitoringSession session) {
    Navigator.of(context).pushNamed(
      AppRoutes.serviceDetails,
      arguments: ServiceDetailsArgs(
        serviceId: session.serviceId,
        monitoring: true,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${Formatters.greeting()},',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.firstName ?? 'Tutor',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${Formatters.weekday(DateTime.now())}, '
                '${Formatters.dateLong(DateTime.now())}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Stack(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.blue,
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineSummary extends StatelessWidget {
  const _TimelineSummary({
    required this.session,
    required this.onDetails,
    required this.onSimulate,
  });

  final MonitoringSession session;
  final VoidCallback onDetails;
  final VoidCallback onSimulate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionHeader(
            title: 'Etapas do atendimento',
            subtitle: 'Atualizado a cada leitura do cartão RFID',
            actionLabel: 'Detalhes',
            onAction: onDetails,
          ),
          const SizedBox(height: 16),
          StageTimeline(session: session, compact: true, maxItems: 4),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Icon(Icons.nfc_rounded, size: 18, color: AppColors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Simular a aproximação do cartão no leitor ESP32',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton(
                onPressed: onSimulate,
                style: TextButton.styleFrom(foregroundColor: AppColors.orange),
                child: const Text('Simular'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoServiceCard extends StatelessWidget {
  const _NoServiceCard({required this.onSchedule, required this.onRestartDemo});

  final VoidCallback onSchedule;
  final VoidCallback onRestartDemo;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded,
              size: 34,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum atendimento em andamento',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Quando o cartão RFID do seu pet for lido no pet shop, o '
            'acompanhamento aparece aqui em tempo real.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onSchedule,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Agendar um serviço'),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: onRestartDemo,
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text('Reiniciar atendimento demonstrativo'),
            style: TextButton.styleFrom(foregroundColor: AppColors.orange),
          ),
        ],
      ),
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments({required this.onSchedule});

  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sem agendamentos ativos',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Que tal marcar o próximo banho?',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onSchedule, child: const Text('Agendar')),
        ],
      ),
    );
  }
}

class _PetsStrip extends StatelessWidget {
  const _PetsStrip({required this.pets});

  final List<Pet> pets;

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) return const SizedBox.shrink();
    return AppCard(
      onTap: () => MainShell.goToTab(context, 1),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: (pets.length.clamp(1, 3) * 28) + 18,
            height: 44,
            child: Stack(
              children: List<Widget>.generate(pets.length.clamp(1, 3), (int i) {
                return Positioned(
                  left: i * 28,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.white,
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: AppColors.blue.withValues(alpha: 0.12),
                      child: Text(
                        pets[i].initial,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${pets.length} pet(s) cadastrado(s)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  pets.map((Pet p) => p.name).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
