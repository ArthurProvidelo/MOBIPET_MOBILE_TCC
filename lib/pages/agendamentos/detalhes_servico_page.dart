import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agendamento.dart';
import '../../state/agendamentos_provider.dart';
import '../../state/servicos_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatters.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton.dart';

class DetalhesServicoPage extends StatelessWidget {
  final String agendamentoId;

  const DetalhesServicoPage({super.key, required this.agendamentoId});

  @override
  Widget build(BuildContext context) {
    final agendamentosProvider = context.watch<AgendamentosProvider>();
    final servicosProvider = context.watch<ServicosProvider>();

    Agendamento? agendamento;
    for (final a in agendamentosProvider.agendamentos) {
      if (a.id == agendamentoId) {
        agendamento = a;
        break;
      }
    }

    if (agendamento == null && agendamentosProvider.carregando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do serviço')),
        body: Shimmer(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              CardSkeleton(linhas: 0),
              SizedBox(height: 16),
              CardSkeleton(linhas: 6),
            ],
          ),
        ),
      );
    }

    if (agendamento == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do serviço')),
        body: const SafeArea(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Agendamento não encontrado',
            message: 'Este agendamento pode ter sido removido ou já não existe mais.',
          ),
        ),
      );
    }

    final servico = servicosProvider.porId(agendamento.servicoId);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do serviço')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(agendamento.servicoNome ?? servico?.nome ?? 'Serviço', style: Theme.of(context).textTheme.titleLarge),
                      _statusBadge(agendamento.status),
                    ],
                  ),
                  if (servico != null) ...[
                    const SizedBox(height: 6),
                    Text(servico.descricao, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _linha(context, Icons.pets_outlined, 'Pet', agendamento.petNome ?? '—'),
                  const Divider(height: 24),
                  _linha(context, Icons.badge_outlined, 'Profissional', agendamento.funcionarioNome ?? '—'),
                  const Divider(height: 24),
                  _linha(context, Icons.calendar_today_outlined, 'Data', DateFormatters.diaSemanaEData(agendamento.dateTime)),
                  const Divider(height: 24),
                  _linha(context, Icons.access_time_rounded, 'Horário', DateFormatters.hora(agendamento.dateTime)),
                  if (servico != null) ...[
                    const Divider(height: 24),
                    _linha(context, Icons.timelapse_rounded, 'Duração estimada', servico.duracaoFormatada),
                    const Divider(height: 24),
                    _linha(context, Icons.payments_outlined, 'Valor', 'R\$ ${servico.preco.toStringAsFixed(2)}'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(BuildContext context, IconData icon, String label, String valor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text(valor, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  Widget _statusBadge(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.agendado:
        return CustomBadge(label: 'Agendado', color: AppColors.primary);
      case StatusAgendamento.emAndamento:
        return CustomBadge(label: 'Em andamento', color: AppColors.accent);
      case StatusAgendamento.concluido:
        return CustomBadge(label: 'Concluído', color: AppColors.success);
      case StatusAgendamento.cancelado:
        return CustomBadge(label: 'Cancelado', color: AppColors.danger);
    }
  }
}
