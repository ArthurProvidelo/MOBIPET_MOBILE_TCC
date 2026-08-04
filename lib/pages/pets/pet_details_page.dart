import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../models/monitoring_session.dart';
import '../../models/pet.dart';
import '../../services/appointment_repository.dart';
import '../../services/monitoring_service.dart';
import '../../services/pet_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stage_progress_bar.dart';
import '../../widgets/stage_timeline.dart';
import '../appointments/service_details_page.dart';

/// Detalhes do pet: dados, atendimento atual e histórico.
class PetDetailsPage extends StatelessWidget {
  const PetDetailsPage({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context) {
    final PetRepository pets = context.watch<PetRepository>();
    final AppointmentRepository appointments = context
        .watch<AppointmentRepository>();
    final MonitoringSession? session = context
        .watch<MonitoringService>()
        .session;
    final Pet? pet = pets.byId(petId);

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do pet')),
        body: const EmptyState(
          icon: Icons.pets_rounded,
          title: 'Pet não encontrado',
          message: 'Este pet pode ter sido removido da sua conta.',
        ),
      );
    }

    final bool inService = session?.petId == pet.id;
    final List<Appointment> history = appointments.byPet(pet.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 232,
            pinned: true,
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
            actions: <Widget>[
              IconButton(
                tooltip: 'Editar',
                onPressed: () async {
                  final Object? result = await Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.petForm, arguments: pet);
                  if (!context.mounted || result is! String) return;
                  AppFeedback.success(context, result);
                  if (result.contains('removido')) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.edit_rounded),
              ),
              const SizedBox(width: 6),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 18),
                      PetAvatar(pet: pet, size: 96, showBorder: true),
                      const SizedBox(height: 12),
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pet.breed} · ${pet.ageLabel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                if (inService && session != null) ...<Widget>[
                  _CurrentAttendance(
                    session: session,
                    onDetails: () => Navigator.of(context).pushNamed(
                      AppRoutes.serviceDetails,
                      arguments: ServiceDetailsArgs(
                        serviceId: session.serviceId,
                        monitoring: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                const SectionHeader(title: 'Informações'),
                const SizedBox(height: 14),
                _InfoGrid(pet: pet),
                if (pet.notes.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  AppCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.sticky_note_2_outlined,
                          color: AppColors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Observações',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pet.notes,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                SectionHeader(
                  title: 'Histórico de atendimentos',
                  subtitle: '${history.length} registro(s)',
                ),
                const SizedBox(height: 14),
                if (history.isEmpty)
                  AppCard(
                    child: Text(
                      'Nenhum atendimento registrado para ${pet.name} ainda.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...history.map(
                    (Appointment appointment) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AppointmentCard(
                        appointment: appointment,
                        pet: pet,
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
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.newAppointment, arguments: pet.id),
                  icon: const Icon(Icons.event_available_rounded, size: 20),
                  label: Text('Agendar serviço para ${pet.name}'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentAttendance extends StatelessWidget {
  const _CurrentAttendance({required this.session, required this.onDetails});

  final MonitoringSession session;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionHeader(
            title: 'Atendimento de hoje',
            subtitle: 'Iniciado às ${Formatters.time(session.startedAt)}',
            actionLabel: 'Detalhes',
            onAction: onDetails,
          ),
          const SizedBox(height: 16),
          StageProgressBar(
            completed: session.completedCount,
            total: session.totalCount,
          ),
          const SizedBox(height: 18),
          StageTimeline(session: session, compact: true, maxItems: 3),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final List<List<String>> items = <List<String>>[
      <String>['Idade', pet.ageLabel],
      <String>['Peso', '${pet.weightKg.toStringAsFixed(1)} kg'],
      <String>['Porte', pet.size.label],
      <String>['Sexo', pet.gender],
      <String>['Espécie', pet.species.label],
      <String>['Nascimento', Formatters.date(pet.birthDate)],
    ];
    final List<IconData> icons = <IconData>[
      Icons.cake_rounded,
      Icons.monitor_weight_rounded,
      Icons.straighten_rounded,
      Icons.wc_rounded,
      Icons.pets_rounded,
      Icons.event_rounded,
    ];

    return Column(
      children: <Widget>[
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: List<Widget>.generate(items.length, (int index) {
            return AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Icon(icons[index], size: 19, color: AppColors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          items[index][0],
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          items[index][1],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        if (pet.rfidTag != null) ...<Widget>[
          const SizedBox(height: 12),
          AppCard(
            color: AppColors.blue.withValues(alpha: 0.06),
            elevated: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                const Icon(Icons.nfc_rounded, color: AppColors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Cartão RFID vinculado',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        pet.rfidTag!,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
