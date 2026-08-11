import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/atendimento.dart';
import '../../services/mock_data.dart';
import '../../state/atendimento_provider.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatters.dart';
import '../../utils/stage_utils.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/stage_timeline.dart';

class DetalhesServicoPage extends StatefulWidget {
  final String atendimentoId;

  const DetalhesServicoPage({super.key, required this.atendimentoId});

  @override
  State<DetalhesServicoPage> createState() => _DetalhesServicoPageState();
}

class _DetalhesServicoPageState extends State<DetalhesServicoPage> {
  Atendimento? _atendimento;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final provider = context.read<AtendimentoProvider>();
    final atual = provider.atual;
    final atendimento = (atual != null && atual.id == widget.atendimentoId) ? atual : await provider.obter(widget.atendimentoId);
    if (!mounted) return;
    setState(() {
      _atendimento = atendimento;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Serviço')),
      body: SafeArea(
        child: _carregando
            ? const LoadingView()
            : _atendimento == null
                ? const Center(child: Text('Atendimento não encontrado', style: TextStyle(color: AppColors.textSecondary)))
                : Consumer<AtendimentoProvider>(
                    builder: (context, provider, _) {
                      final atendimento = (provider.atual?.id == widget.atendimentoId) ? provider.atual! : _atendimento!;
                      final pet = context.watch<PetsProvider>().porId(atendimento.petId);
                      final servico = MockData.servicos.firstWhere((s) => s.id == atendimento.servicoId);

                      return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          CustomCard(
                            child: Row(
                              children: [
                                if (pet != null)
                                  CircleAvatar(radius: 28, backgroundImage: NetworkImage(pet.imageUrl)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(pet?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                      const SizedBox(height: 4),
                                      Text(servico.nome, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Iniciado às ${DateFormatters.hora(atendimento.iniciadoEm)}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomCard(
                            child: StageTimeline(atendimento: atendimento, compact: false),
                          ),
                          const SizedBox(height: 20),
                          if (atendimento.isFinalizado)
                            CustomCard(
                              child: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: AppColors.success),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Atendimento concluído! O pet está pronto para retirada.',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            PrimaryButton(
                              label: 'Simular leitura RFID',
                              icon: Icons.nfc,
                              loading: provider.isAvancando,
                              onPressed: () async {
                                await provider.simularLeituraRfid();
                                if (!context.mounted) return;
                                final novo = provider.atual!;
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
                      );
                    },
                  ),
      ),
    );
  }
}
