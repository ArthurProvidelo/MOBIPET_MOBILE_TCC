import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agendamento.dart';
import '../../services/mock_data.dart';
import '../../state/agendamentos_provider.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import 'novo_agendamento_page.dart';

class AgendamentosPage extends StatelessWidget {
  const AgendamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final agendamentosProvider = context.watch<AgendamentosProvider>();
    final petsProvider = context.watch<PetsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NovoAgendamentoPage())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-agendamentos',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NovoAgendamentoPage())),
        icon: const Icon(Icons.add),
        label: const Text('Novo Agendamento'),
      ),
      body: agendamentosProvider.isLoading
          ? const LoadingView()
          : agendamentosProvider.agendamentos.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'Nenhum agendamento ainda',
                    subtitle: 'Agende um serviço para acompanhar por aqui.',
                    actionLabel: 'Novo agendamento',
                    onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NovoAgendamentoPage())),
                  ),
                )
              : _buildLista(context, agendamentosProvider, petsProvider),
    );
  }

  Widget _buildLista(BuildContext context, AgendamentosProvider agendamentosProvider, PetsProvider petsProvider) {
    final agendamentos = List.of(agendamentosProvider.agendamentos)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final grupos = <String, List<Agendamento>>{};
    for (final agendamento in agendamentos) {
      final grupo = DateFormatters.grupoDoDia(agendamento.dateTime);
      grupos.putIfAbsent(grupo, () => []).add(agendamento);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final entrada in grupos.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 6),
            child: Text(
              entrada.key,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          for (final agendamento in entrada.value) ...[
            _buildAgendamentoCard(context, agendamento, petsProvider),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  Widget _buildAgendamentoCard(BuildContext context, Agendamento agendamento, PetsProvider petsProvider) {
    final pet = petsProvider.porId(agendamento.petId);
    final servico = MockData.servicos.firstWhere((s) => s.id == agendamento.servicoId);

    return CustomCard(
      child: Row(
        children: [
          Column(
            children: [
              Text(DateFormatters.hora(agendamento.dateTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('HORA', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          const VerticalDivider(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(servico.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    CustomBadge(status: agendamento.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Pet: ${pet?.name ?? ''}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (agendamento.status == StatusAgendamento.agendado)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.danger, size: 20),
              tooltip: 'Cancelar',
              onPressed: () async {
                final confirmar = await showConfirmDialog(
                  context,
                  title: 'Cancelar agendamento?',
                  message: '${servico.nome} para ${pet?.name ?? ''} será cancelado.',
                  confirmLabel: 'Cancelar agendamento',
                  danger: true,
                );
                if (!context.mounted || !confirmar) return;
                await context.read<AgendamentosProvider>().cancelar(agendamento.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Agendamento cancelado')),
                );
              },
            ),
        ],
      ),
    );
  }
}
