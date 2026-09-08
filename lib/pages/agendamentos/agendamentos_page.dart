import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agendamento.dart';
import '../../state/agendamentos_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import 'detalhes_servico_page.dart';
import 'novo_agendamento_page.dart';

class AgendamentosPage extends StatelessWidget {
  const AgendamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final agendamentosProvider = context.watch<AgendamentosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos')),
      body: SafeArea(
        child: agendamentosProvider.carregando
            ? const LoadingView()
            : agendamentosProvider.agendamentos.isEmpty
                ? EmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'Nenhum agendamento',
                    message: 'Agende um serviço para o seu pet.',
                    actionLabel: 'Novo agendamento',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NovoAgendamentoPage()),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: agendamentosProvider.carregar,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: agendamentosProvider.agendamentos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final agendamento = agendamentosProvider.agendamentos[index];
                        // Em andamento não pode ser removido; agendado é
                        // cancelado; concluído/cancelado é excluído do histórico.
                        final podeRemover = agendamento.status != StatusAgendamento.emAndamento;
                        final ehCancelamento = agendamento.status == StatusAgendamento.agendado;
                        return Dismissible(
                          key: ValueKey(agendamento.id),
                          direction: podeRemover ? DismissDirection.endToStart : DismissDirection.none,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: AppColors.white),
                          ),
                          confirmDismiss: (_) async {
                            if (!podeRemover) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Não é possível excluir um agendamento em andamento.')),
                              );
                              return false;
                            }
                            return ConfirmDialog.show(
                              context,
                              title: ehCancelamento ? 'Cancelar agendamento' : 'Excluir agendamento',
                              message: ehCancelamento
                                  ? 'Deseja cancelar este agendamento?'
                                  : 'Deseja excluir este agendamento do histórico?',
                              confirmLabel: ehCancelamento ? 'Cancelar agendamento' : 'Excluir',
                              destructive: true,
                            );
                          },
                          onDismissed: (_) async {
                            final provider = context.read<AgendamentosProvider>();
                            if (ehCancelamento) {
                              await provider.cancelar(agendamento.id);
                            } else {
                              await provider.excluir(agendamento.id);
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ehCancelamento ? 'Agendamento cancelado' : 'Agendamento excluído'),
                              ),
                            );
                          },
                          child: _AgendamentoCard(agendamento: agendamento),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NovoAgendamentoPage()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo agendamento'),
      ),
    );
  }
}

class _AgendamentoCard extends StatelessWidget {
  final Agendamento agendamento;

  const _AgendamentoCard({required this.agendamento});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetalhesServicoPage(agendamentoId: agendamento.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${agendamento.petNome ?? 'Pet'} · ${agendamento.servicoNome ?? 'Serviço'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _statusBadge(agendamento.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(DateFormatters.dataEHora(agendamento.dateTime), style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          if (agendamento.status == StatusAgendamento.agendado) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final confirmar = await ConfirmDialog.show(
                    context,
                    title: 'Cancelar agendamento',
                    message: 'Deseja cancelar este agendamento?',
                    confirmLabel: 'Cancelar agendamento',
                    destructive: true,
                  );
                  if (!context.mounted || !confirmar) return;
                  await context.read<AgendamentosProvider>().cancelar(agendamento.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Agendamento cancelado')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Cancelar'),
              ),
            ),
          ] else if (agendamento.status == StatusAgendamento.concluido ||
              agendamento.status == StatusAgendamento.cancelado) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final confirmar = await ConfirmDialog.show(
                    context,
                    title: 'Excluir agendamento',
                    message: 'Deseja excluir este agendamento do histórico?',
                    confirmLabel: 'Excluir',
                    destructive: true,
                  );
                  if (!context.mounted || !confirmar) return;
                  await context.read<AgendamentosProvider>().excluir(agendamento.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Agendamento excluído')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Excluir'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.agendado:
        return const CustomBadge(label: 'Agendado', color: AppColors.primary, icon: Icons.event_rounded);
      case StatusAgendamento.emAndamento:
        return const CustomBadge(label: 'Em andamento', color: AppColors.accent, icon: Icons.autorenew_rounded);
      case StatusAgendamento.concluido:
        return const CustomBadge(label: 'Concluído', color: AppColors.success, icon: Icons.check_circle_rounded);
      case StatusAgendamento.cancelado:
        return const CustomBadge(label: 'Cancelado', color: AppColors.danger, icon: Icons.cancel_rounded);
    }
  }
}
