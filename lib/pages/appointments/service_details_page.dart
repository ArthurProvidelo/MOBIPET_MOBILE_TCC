import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../models/monitoring_session.dart';
import '../../models/pet.dart';
import '../../models/pet_service.dart';
import '../../models/service_stage.dart';
import '../../services/appointment_repository.dart';
import '../../services/monitoring_service.dart';
import '../../services/pet_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stage_progress_bar.dart';
import '../../widgets/stage_timeline.dart';
import '../../widgets/status_badge.dart';

/// Argumentos da tela de detalhes do serviço.
class ServiceDetailsArgs {
  const ServiceDetailsArgs({
    required this.serviceId,
    this.appointmentId,
    this.monitoring = false,
  });

  final String serviceId;
  final String? appointmentId;

  /// Abre a tela focada no acompanhamento em tempo real.
  final bool monitoring;
}

/// Detalhes do serviço: descrição, etapas, acompanhamento em tempo real
/// e dados do agendamento relacionado.
class ServiceDetailsPage extends StatelessWidget {
  const ServiceDetailsPage({super.key, required this.args});

  final ServiceDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    final AppointmentRepository repository = context
        .watch<AppointmentRepository>();
    final PetRepository pets = context.watch<PetRepository>();
    final MonitoringService monitoring = context.watch<MonitoringService>();
    final PetService? service = repository.serviceById(args.serviceId);
    final Appointment? appointment = repository.byId(args.appointmentId);
    final MonitoringSession? session = monitoring.session;
    final bool showMonitoring =
        session != null &&
        (args.monitoring || session.serviceId == args.serviceId);

    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do serviço')),
        body: const EmptyState(
          icon: Icons.help_outline_rounded,
          title: 'Serviço indisponível',
          message: 'Este serviço não faz parte do catálogo atual.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      bottomNavigationBar: showMonitoring
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              color: AppColors.white,
              child: PrimaryButton(
                label: 'Agendar ${service.name}',
                icon: Icons.event_available_rounded,
                onPressed: () async {
                  final Object? result = await Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.newAppointment);
                  if (!context.mounted || result is! String) return;
                  AppFeedback.success(context, result);
                },
              ),
            ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: <Widget>[
            _ServiceHeader(service: service),
            const SizedBox(height: 20),
            if (showMonitoring) ...<Widget>[
              _MonitoringCard(session: session, pet: pets.byId(session.petId)),
              const SizedBox(height: 20),
            ],
            if (appointment != null) ...<Widget>[
              _AppointmentInfo(
                appointment: appointment,
                pet: pets.byId(appointment.petId),
              ),
              const SizedBox(height: 20),
            ],
            const SectionHeader(title: 'Sobre o serviço'),
            const SizedBox(height: 12),
            AppCard(
              child: Text(
                service.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Etapas monitoradas',
              subtitle: '${service.stages.length} etapas registradas por RFID',
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: List<Widget>.generate(service.stages.length, (
                  int index,
                ) {
                  final ServiceStage stage = service.stages[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == service.stages.length - 1 ? 0 : 14,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            stage.icon,
                            size: 18,
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                stage.label,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                stage.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceHeader extends StatelessWidget {
  const _ServiceHeader({required this.service});

  final PetService service;

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
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(service.icon, size: 30, color: AppColors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  service.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      service.durationLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      Formatters.currency(service.price),
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitoringCard extends StatelessWidget {
  const _MonitoringCard({required this.session, required this.pet});

  final MonitoringSession session;
  final Pet? pet;

  void _simulate(BuildContext context) {
    final ServiceStage? stage = context
        .read<MonitoringService>()
        .registerRfidRead();
    if (stage == null) {
      AppFeedback.info(context, 'Todas as etapas já foram concluídas.');
      return;
    }
    AppFeedback.rfid(
      context,
      'Etapa "${stage.label}" registrada às '
      '${Formatters.time(DateTime.now())}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (pet != null) PetAvatar(pet: pet!, size: 48),
              if (pet != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      pet?.name ?? 'Atendimento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Check-in às ${Formatters.time(session.startedAt)} · '
                      '${session.attendantName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: session.isFinished ? 'Finalizado' : 'Ao vivo',
                color: session.isFinished
                    ? AppColors.success
                    : AppColors.orange,
                dense: true,
                icon: Icons.circle,
              ),
            ],
          ),
          const SizedBox(height: 18),
          StageProgressBar(
            completed: session.completedCount,
            total: session.totalCount,
          ),
          const SizedBox(height: 20),
          StageTimeline(session: session),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Cartão ${session.rfidTag}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'Previsão de término: '
                      '${Formatters.time(session.estimatedEnd)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _simulate(context),
                icon: const Icon(Icons.nfc_rounded, size: 18),
                label: const Text('Simular leitura'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  foregroundColor: AppColors.orange,
                  side: const BorderSide(color: AppColors.orange, width: 1.3),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentInfo extends StatelessWidget {
  const _AppointmentInfo({required this.appointment, required this.pet});

  final Appointment appointment;
  final Pet? pet;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Seu agendamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              StatusBadge(
                label: appointment.status.label,
                color: appointment.status.color,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.pets_rounded,
            label: 'Pet',
            value: pet?.name ?? 'Pet removido',
          ),
          _InfoRow(
            icon: Icons.event_rounded,
            label: 'Data',
            value:
                '${Formatters.weekday(appointment.dateTime)}, '
                '${Formatters.dateLong(appointment.dateTime)}',
          ),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Horário',
            value: Formatters.time(appointment.dateTime),
          ),
          if (appointment.notes.isNotEmpty)
            _InfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Observações',
              value: appointment.notes,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.blue),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
