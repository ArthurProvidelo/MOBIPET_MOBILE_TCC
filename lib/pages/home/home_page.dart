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
import '../../utils/haptics.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/section_header.dart';
import '../../utils/stage_utils.dart';
import '../../widgets/stage_badge.dart';
import '../../widgets/stage_timeline.dart';
import '../agendamentos/agendamentos_page.dart';
import '../pets/pet_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final usuario = appState.usuario;
    final foto = appState.fotoPerfil;
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
            Haptics.light();
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
                        Text('$saudacao,', style: Theme.of(context).textTheme.bodyLarge),
                        Text(primeiroNome, style: Theme.of(context).textTheme.headlineLarge),
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
                      image: foto != null ? DecorationImage(image: FileImage(foto), fit: BoxFit.cover) : null,
                    ),
                    child: foto == null
                        ? Icon(Icons.person_outline_rounded, color: AppColors.primary)
                        : null,
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
                ...agendamentosProvider.proximos.take(3).toList().asMap().entries.map(
                      (e) => FadeSlideIn(
                        delay: Duration(milliseconds: e.key * 70),
                        offsetY: 16,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AgendamentoResumo(agendamento: e.value, pets: petsProvider),
                        ),
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

    final agendamento = provider.atual;
    final progresso = provider.progresso;
    // Se o atendimento já foi finalizado (Concluído) ou cancelado, ele não é
    // mais "atual": some do card e volta o estado vazio.
    if (agendamento == null || progresso == null || agendamento.isFinalizado) {
      return CustomCard(
        child: Row(
          children: [
            Icon(Icons.event_available_outlined, color: AppColors.textSecondary, size: 28),
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

    final pet = petsProvider.porId(agendamento.petId);
    final servico = servicosProvider.porId(agendamento.servicoId);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.background),
                child: Icon(Icons.pets_rounded, color: AppColors.primary),
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
                  icon: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 18),
          StageProgressBar(
            progresso: progresso.progresso,
            etapasConcluidas: progresso.etapasConcluidas,
            totalEtapas: progresso.totalEtapas,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: StageBadge(status: agendamento.status, etapa: progresso.etapaAtual),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          StageTimeline(agendamento: agendamento, progresso: progresso),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.avancando || agendamento.isFinalizado
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await provider.simularLeituraRfid();
                      if (!context.mounted) return;
                      if (!ok) {
                        Haptics.error();
                        messenger.showSnackBar(SnackBar(
                          content: Text(
                            provider.erro ?? 'Não foi possível avançar a etapa.',
                          ),
                        ));
                        return;
                      }
                      Haptics.success();
                      // Check-in / finalização mudaram o status no backend:
                      // recarrega as telas que dependem disso.
                      if (provider.ultimaAcaoMudouBackend) {
                        context.read<AgendamentosProvider>().carregar();
                        context.read<PetsProvider>().carregar();
                      }
                    },
              icon: provider.avancando
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.nfc_rounded, size: 18),
              label: Text(StageUtils.rotuloAcao(agendamento, progresso)),
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
            child: Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
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
