import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agendamento.dart';
import '../../services/agendamento_service.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/etapas_servico.dart';
import '../../utils/stage_utils.dart';
import '../../widgets/celebration_overlay.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/stage_badge.dart';
import '../../widgets/stage_timeline.dart';

/// Mostra o acompanhamento do atendimento filtrado para um único pet,
/// reaproveitando o mesmo cartão exibido na Home.
class PetAcompanhamentoPage extends StatefulWidget {
  final String petId;

  const PetAcompanhamentoPage({super.key, required this.petId});

  @override
  State<PetAcompanhamentoPage> createState() => _PetAcompanhamentoPageState();
}

class _PetAcompanhamentoPageState extends State<PetAcompanhamentoPage> {
  final _service = AgendamentoService();
  Agendamento? _agendamento;
  int _subEtapaLocal = 0;
  bool _carregando = true;
  bool _avancando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final agendamento = await _service.atualDoPet(widget.petId);
    if (!mounted) return;
    setState(() {
      if (agendamento?.id != _agendamento?.id) _subEtapaLocal = 0;
      _agendamento = agendamento;
      _carregando = false;
    });
  }

  Future<void> _avancar() async {
    final agendamento = _agendamento;
    if (agendamento == null || agendamento.isFinalizado || _avancando) return;
    final progresso = ProgressoEtapas.de(agendamento, subEtapaLocal: _subEtapaLocal);
    final finalizandoAgora = progresso.proximaAcaoFinaliza;
    setState(() => _avancando = true);

    Agendamento? atualizado;
    int subEtapaLocal = _subEtapaLocal;
    bool mudouBackend = false;
    try {
      if (agendamento.status == StatusAgendamento.agendado) {
        atualizado = await _service.iniciar(agendamento.id);
        subEtapaLocal = 1;
        mudouBackend = true;
      } else if (progresso.proximaAcaoFinaliza) {
        atualizado = await _service.avancar(agendamento.id);
        subEtapaLocal = 0;
        mudouBackend = true;
      } else {
        atualizado = agendamento;
        subEtapaLocal = (_subEtapaLocal + 1).clamp(1, progresso.etapas.length - 2);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _avancando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível avançar a etapa: $e')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _agendamento = atualizado;
      _subEtapaLocal = subEtapaLocal;
      _avancando = false;
    });
    if (finalizandoAgora) Celebration.play(context);
    // Mantém a lista de pets/atendimentos em sincronia com o novo status.
    if (mudouBackend) context.read<PetsProvider>().carregar();
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetsProvider>().porId(widget.petId);
    final agendamento = _agendamento;
    final progresso = agendamento == null
        ? null
        : ProgressoEtapas.de(agendamento, subEtapaLocal: _subEtapaLocal);

    return Scaffold(
      appBar: AppBar(title: Text(pet?.name ?? 'Acompanhamento')),
      body: SafeArea(
        child: pet == null
            ? const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Pet não encontrado',
                message: 'Este pet pode ter sido removido ou já não existe mais.',
              )
            : RefreshIndicator(
                onRefresh: _carregar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    if (_carregando)
                      const AtendimentoCardSkeleton()
                    else if (_agendamento == null)
                      SizedBox(
                        height: 420,
                        child: EmptyState(
                          icon: Icons.event_available_outlined,
                          title: 'Nada em andamento',
                          message: 'Nenhum atendimento em andamento para ${pet.name} no momento.',
                        ),
                      )
                    else
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Hero(
                                  tag: 'pet-avatar-${pet.id}',
                                  child: PetAvatar(pet: pet, size: 52),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(pet.name, style: Theme.of(context).textTheme.titleMedium),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            StageProgressBar(
                              progresso: progresso!.progresso,
                              etapasConcluidas: progresso.etapasConcluidas,
                              totalEtapas: progresso.totalEtapas,
                            ),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StageBadge(status: agendamento!.status, etapa: progresso.etapaAtual),
                            ),
                            const SizedBox(height: 18),
                            const Divider(),
                            const SizedBox(height: 14),
                            StageTimeline(agendamento: agendamento, progresso: progresso),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _avancando || agendamento.isFinalizado ? null : _avancar,
                                icon: _avancando
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
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
