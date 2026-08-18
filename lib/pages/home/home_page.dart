import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agendamento.dart';
import '../../state/agendamentos_provider.dart';
import '../../state/app_state.dart';
import '../../state/atendimento_provider.dart';
import '../../state/pets_provider.dart';
import '../../state/servicos_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatters.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stage_badge.dart';
import '../../widgets/stage_timeline.dart';
import '../agendamentos/agendamentos_page.dart';
import '../pets/pet_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AppState>().usuario;
    final atendimentoProvider = context.watch<AtendimentoProvider>();
    final petsProvider = context.watch<PetsProvider>();
    final agendamentosProvider = context.watch<AgendamentosProvider>();
    final servicosProvider = context.watch<ServicosProvider>();

    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final primeiroNome = usuario.nome.split(' ').first;
    final saudacao = _saudacao();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              petsProvider.carregar(),
              agendamentosProvider.carregar(),
              atendimentoProvider.carregar(),
              servicosProvider.carregar(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$saudacao,', style: Theme.of(context).textTheme.bodyMedium),
                        Text(primeiroNome, style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      color: AppColors.background,
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _AtendimentoAtualCard(
                provider: atendimentoProvider,
                petsProvider: petsProvider,
                servicosProvider: servicosProvider,
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Próximos agendamentos',
                actionLabel: 'Ver todos',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AgendamentosPage()),
                ),
              ),
              const SizedBox(height: 12),
              if (agendamentosProvider.carregando)
                const Padding(padding: EdgeInsets.all(24), child: LoadingView())
              else if (agendamentosProvider.proximos.isEmpty)
                const CustomCard(
                  child: Text('Nenhum agendamento futuro no momento.'),
                )
              else
                ...agendamentosProvider.proximos.take(3).map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AgendamentoResumo(agendamento: a, pets: petsProvider),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _saudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}

class _AtendimentoAtualCard extends StatelessWidget {
  final AtendimentoProvider provider;
  final PetsProvider petsProvider;
  final ServicosProvider servicosProvider;

  const _AtendimentoAtualCard({required this.provider, required this.petsProvider, required this.servicosProvider});

  @override
  Widget build(BuildContext context) {
    if (provider.carregando) {
      return const CustomCard(child: Padding(padding: EdgeInsets.all(12), child: LoadingView()));
    }

    final atendimento = provider.atual;
    if (atendimento == null) {
      return CustomCard(
        child: Row(
          children: [
            const Icon(Icons.event_available_outlined, color: AppColors.textSecondary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Nenhum atendimento em andamento no momento.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final pet = petsProvider.porId(atendimento.petId);
    final servico = servicosProvider.porId(atendimento.servicoId);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.background),
                child: const Icon(Icons.pets_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet?.name ?? 'Pet', style: Theme.of(context).textTheme.titleMedium),
                    Text(servico?.nome ?? 'Serviço', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              if (pet != null)
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PetDetailsPage(petId: pet.id)),
                  ),
                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 18),
          StageProgressBar(
            progresso: atendimento.progresso,
            etapasConcluidas: atendimento.etapasConcluidas,
            totalEtapas: atendimento.totalEtapas,
          ),
          const SizedBox(height: 18),
          Align(alignment: Alignment.centerLeft, child: StageBadge(etapa: atendimento.etapaAtual)),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          StageTimeline(atendimento: atendimento, compacto: true),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.avancando || atendimento.isFinalizado
                  ? null
                  : () => provider.simularLeituraRfid(),
              icon: provider.avancando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.nfc_rounded, size: 18),
              label: Text(atendimento.isFinalizado ? 'Atendimento concluído' : 'Simular leitura RFID'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendamentoResumo extends StatelessWidget {
  final Agendamento agendamento;
  final PetsProvider pets;

  const _AgendamentoResumo({required this.agendamento, required this.pets});

  @override
  Widget build(BuildContext context) {
    final pet = pets.porId(agendamento.petId);

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${pet?.name ?? 'Pet'} · ${agendamento.servicoNome ?? 'Serviço'}', style: Theme.of(context).textTheme.titleMedium),
                Text(DateFormatters.dataEHora(agendamento.dateTime), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
