import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agendamento.dart';
import '../../services/mock_data.dart';
import '../../state/agendamentos_provider.dart';
import '../../state/app_state.dart';
import '../../state/atendimento_provider.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatters.dart';
import '../../utils/stage_utils.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stage_timeline.dart';
import '../agendamentos/detalhes_servico_page.dart';
import '../agendamentos/novo_agendamento_page.dart';
import '../pets/pet_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AppState>().currentUser;
    final petsProvider = context.watch<PetsProvider>();
    final agendamentosProvider = context.watch<AgendamentosProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<PetsProvider>().carregar(),
              context.read<AgendamentosProvider>().carregar(),
              context.read<AtendimentoProvider>().carregar(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${usuario?.primeiroNome ?? ''}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text('Tudo certo com seus pets hoje?', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: usuario?.avatarUrl != null ? NetworkImage(usuario!.avatarUrl!) : null,
                    child: usuario?.avatarUrl == null ? const Icon(Icons.person) : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Atendimento atual'),
              const SizedBox(height: 12),
              _buildAtendimentoAtual(context, petsProvider),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Próximos agendamentos',
                actionLabel: agendamentosProvider.proximos.isNotEmpty ? 'Ver todos' : null,
                onAction: agendamentosProvider.proximos.isNotEmpty
                    ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NovoAgendamentoPage()))
                    : null,
              ),
              const SizedBox(height: 12),
              _buildProximosAgendamentos(context, agendamentosProvider, petsProvider),
              const SizedBox(height: 24),
              SectionHeader(title: 'Meus Pets (${petsProvider.pets.length})'),
              const SizedBox(height: 12),
              _buildPetsRow(context, petsProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAtendimentoAtual(BuildContext context, PetsProvider petsProvider) {
    return Consumer<AtendimentoProvider>(
      builder: (context, atendimentoProvider, _) {
        if (atendimentoProvider.isLoading) {
          return const CustomCard(child: SizedBox(height: 90, child: Center(child: CircularProgressIndicator())));
        }
        final atendimento = atendimentoProvider.atual;
        if (atendimento == null) {
          return const CustomCard(
            child: EmptyState(
              icon: Icons.pets_outlined,
              title: 'Nenhum atendimento em andamento',
              subtitle: 'Assim que seu pet fizer check-in no pet shop, o progresso aparece aqui.',
            ),
          );
        }
        final pet = petsProvider.porId(atendimento.petId);
        final servico = MockData.servicos.firstWhere((s) => s.id == atendimento.servicoId);

        return CustomCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetalhesServicoPage(atendimentoId: atendimento.id)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${servico.nome} · ${pet?.name ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 16),
              StageTimeline(atendimento: atendimento, compact: true),
              const SizedBox(height: 16),
              PrimaryButton(
                label: atendimento.isFinalizado ? 'Atendimento finalizado' : 'Simular leitura RFID',
                icon: Icons.nfc,
                loading: atendimentoProvider.isAvancando,
                onPressed: atendimento.isFinalizado
                    ? null
                    : () async {
                        await atendimentoProvider.simularLeituraRfid();
                        if (!context.mounted) return;
                        final novo = atendimentoProvider.atual!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              novo.isFinalizado
                                  ? 'Atendimento finalizado! 🎉'
                                  : 'Etapa avançada para: ${StageUtils.labelDe(novo.etapaAtual)}',
                            ),
                          ),
                        );
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProximosAgendamentos(BuildContext context, AgendamentosProvider provider, PetsProvider petsProvider) {
    if (provider.isLoading) {
      return const CustomCard(child: SizedBox(height: 60, child: Center(child: CircularProgressIndicator())));
    }
    final proximos = provider.proximos.take(3).toList();
    if (proximos.isEmpty) {
      return CustomCard(
        child: EmptyState(
          icon: Icons.event_available_outlined,
          title: 'Nenhum agendamento futuro',
          actionLabel: 'Agendar serviço',
          onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NovoAgendamentoPage())),
        ),
      );
    }
    return Column(
      children: [
        for (final agendamento in proximos) ...[
          _buildAgendamentoCard(context, agendamento, petsProvider),
          const SizedBox(height: 12),
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
          Icon(servico.icone, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(servico.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  '${pet?.name ?? ''} · ${DateFormatters.relativoAoDia(agendamento.dateTime)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          CustomBadge(status: agendamento.status),
        ],
      ),
    );
  }

  Widget _buildPetsRow(BuildContext context, PetsProvider petsProvider) {
    if (petsProvider.pets.isEmpty) {
      return const CustomCard(
        child: EmptyState(icon: Icons.pets_outlined, title: 'Nenhum pet cadastrado ainda'),
      );
    }
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: petsProvider.pets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final pet = petsProvider.pets[index];
          return PetCard(
            pet: pet,
            compact: true,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetDetailsPage(pet: pet))),
          );
        },
      ),
    );
  }
}
