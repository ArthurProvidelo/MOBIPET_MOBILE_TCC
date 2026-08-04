import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../services/appointment_repository.dart';
import '../../services/pet_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/feedback.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_placeholder.dart';
import 'service_details_page.dart';

/// Lista de agendamentos, separada entre ativos e histórico.
class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentRepository repository = context
        .watch<AppointmentRepository>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agendamentos'),
          bottom: const TabBar(
            labelColor: AppColors.blue,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.blue,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: AppColors.divider,
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            tabs: <Widget>[
              Tab(text: 'Ativos'),
              Tab(text: 'Histórico'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _newAppointment(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Novo agendamento'),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(
            children: <Widget>[
              _AppointmentList(
                appointments: repository.upcoming,
                loading: repository.isLoading,
                emptyTitle: 'Nenhum agendamento ativo',
                emptyMessage:
                    'Agende um banho, tosa ou hidratação e acompanhe cada '
                    'etapa do atendimento pelo app.',
                emptyAction: 'Novo agendamento',
                cancellable: true,
              ),
              _AppointmentList(
                appointments: repository.history,
                loading: repository.isLoading,
                emptyTitle: 'Nada no histórico',
                emptyMessage:
                    'Os atendimentos concluídos ou cancelados aparecem aqui.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _newAppointment(BuildContext context) async {
    final Object? result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.newAppointment);
    if (!context.mounted || result is! String) return;
    AppFeedback.success(context, result);
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.appointments,
    required this.loading,
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyAction,
    this.cancellable = false,
  });

  final List<Appointment> appointments;
  final bool loading;
  final String emptyTitle;
  final String emptyMessage;
  final String? emptyAction;
  final bool cancellable;

  Future<void> _cancel(BuildContext context, Appointment appointment) async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Cancelar agendamento?',
      message:
          'O horário ficará disponível para outros tutores. Você pode '
          'agendar novamente quando quiser.',
      confirmLabel: 'Cancelar agendamento',
      cancelLabel: 'Voltar',
      destructive: true,
      icon: Icons.event_busy_rounded,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<AppointmentRepository>().cancel(appointment.id);
    if (!context.mounted) return;
    AppFeedback.success(context, 'Agendamento cancelado.');
  }

  @override
  Widget build(BuildContext context) {
    final AppointmentRepository repository = context
        .watch<AppointmentRepository>();
    final PetRepository pets = context.watch<PetRepository>();

    if (loading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: LoadingList(),
      );
    }

    if (appointments.isEmpty) {
      return EmptyState(
        icon: Icons.event_note_rounded,
        title: emptyTitle,
        message: emptyMessage,
        actionLabel: emptyAction,
        onAction: emptyAction == null
            ? null
            : () => AppointmentsPage._newAppointment(context),
      );
    }

    return RefreshIndicator(
      onRefresh: repository.refresh,
      color: AppColors.blue,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        itemCount: appointments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (BuildContext context, int index) {
          final Appointment appointment = appointments[index];
          return AppointmentCard(
            appointment: appointment,
            pet: pets.byId(appointment.petId),
            service: repository.serviceById(appointment.serviceId),
            onCancel: cancellable ? () => _cancel(context, appointment) : null,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.serviceDetails,
              arguments: ServiceDetailsArgs(
                serviceId: appointment.serviceId,
                appointmentId: appointment.id,
              ),
            ),
          );
        },
      ),
    );
  }
}
