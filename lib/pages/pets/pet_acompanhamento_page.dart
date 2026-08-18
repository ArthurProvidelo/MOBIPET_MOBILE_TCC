import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/atendimento.dart';
import '../../services/atendimento_service.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_view.dart';
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
  final _service = AtendimentoService();
  Atendimento? _atendimento;
  bool _carregando = true;
  bool _avancando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final atendimento = await _service.atualDoPet(widget.petId);
    if (!mounted) return;
    setState(() {
      _atendimento = atendimento;
      _carregando = false;
    });
  }

  Future<void> _avancar() async {
    if (_atendimento == null || _atendimento!.isFinalizado || _avancando) return;
    setState(() => _avancando = true);
    final atualizado = await _service.avancarEtapa(_atendimento!.id);
    if (!mounted) return;
    setState(() {
      _atendimento = atualizado;
      _avancando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetsProvider>().porId(widget.petId);

    return Scaffold(
      appBar: AppBar(title: Text(pet?.name ?? 'Acompanhamento')),
      body: SafeArea(
        child: pet == null
            ? const Center(child: Text('Pet não encontrado'))
            : RefreshIndicator(
                onRefresh: _carregar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    if (_carregando)
                      const Padding(padding: EdgeInsets.all(24), child: LoadingView())
                    else if (_atendimento == null)
                      CustomCard(
                        child: Row(
                          children: [
                            const Icon(Icons.event_available_outlined, color: AppColors.textSecondary, size: 28),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Nenhum atendimento em andamento para ${pet.name} no momento.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      CustomCard(
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
                                  child: Text(pet.name, style: Theme.of(context).textTheme.titleMedium),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            StageProgressBar(
                              progresso: _atendimento!.progresso,
                              etapasConcluidas: _atendimento!.etapasConcluidas,
                              totalEtapas: _atendimento!.totalEtapas,
                            ),
                            const SizedBox(height: 18),
                            Align(alignment: Alignment.centerLeft, child: StageBadge(etapa: _atendimento!.etapaAtual)),
                            const SizedBox(height: 18),
                            const Divider(),
                            const SizedBox(height: 14),
                            StageTimeline(atendimento: _atendimento!, compacto: true),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _avancando || _atendimento!.isFinalizado ? null : _avancar,
                                icon: _avancando
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                      )
                                    : const Icon(Icons.nfc_rounded, size: 18),
                                label: Text(_atendimento!.isFinalizado ? 'Atendimento concluído' : 'Simular leitura RFID'),
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
