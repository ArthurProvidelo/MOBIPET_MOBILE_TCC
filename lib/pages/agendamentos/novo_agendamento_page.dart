import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/funcionario.dart';
import '../../models/pet.dart';
import '../../models/servico.dart';
import '../../state/agendamentos_provider.dart';
import '../../state/funcionarios_provider.dart';
import '../../state/pets_provider.dart';
import '../../state/servicos_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/cupertino_pickers.dart';
import '../../utils/date_formatters.dart';
import '../../utils/haptics.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/modal_sheet_appbar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/section_label.dart';
import '../../widgets/skeleton.dart';

class NovoAgendamentoPage extends StatefulWidget {
  const NovoAgendamentoPage({super.key});

  @override
  State<NovoAgendamentoPage> createState() => _NovoAgendamentoPageState();
}

class _NovoAgendamentoPageState extends State<NovoAgendamentoPage> {
  Pet? _petSelecionado;
  Servico? _servicoSelecionado;
  Funcionario? _funcionarioSelecionado;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FuncionariosProvider>().carregar();
    });
  }

  bool get _formValido =>
      _petSelecionado != null &&
      _servicoSelecionado != null &&
      _funcionarioSelecionado != null &&
      _dataSelecionada != null &&
      _horaSelecionada != null;

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    Haptics.selection();
    final data = await showAppDatePicker(
      context,
      initialDate: _dataSelecionada ?? agora,
      minimumDate: agora,
      maximumDate: agora.add(const Duration(days: 90)),
    );
    if (data != null) setState(() => _dataSelecionada = data);
  }

  Future<void> _selecionarHora() async {
    Haptics.selection();
    final hora = await showAppTimePicker(
      context,
      initialTime: _horaSelecionada ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (hora != null) setState(() => _horaSelecionada = hora);
  }

  Future<void> _confirmar() async {
    if (!_formValido) return;
    setState(() => _salvando = true);

    final dateTime = DateTime(
      _dataSelecionada!.year,
      _dataSelecionada!.month,
      _dataSelecionada!.day,
      _horaSelecionada!.hour,
      _horaSelecionada!.minute,
    );

    try {
      await context.read<AgendamentosProvider>().criar(
            petId: _petSelecionado!.id,
            servicoId: _servicoSelecionado!.id,
            funcionarioId: _funcionarioSelecionado!.id,
            dateTime: dateTime,
          );
      if (!mounted) return;
      Haptics.success();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento realizado com sucesso!')),
      );
    } catch (_) {
      if (!mounted) return;
      Haptics.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível criar o agendamento. Tente novamente.')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<PetsProvider>().pets;
    final servicos = context.watch<ServicosProvider>().servicos;
    final funcionariosProvider = context.watch<FuncionariosProvider>();
    final funcionarios = funcionariosProvider.funcionarios;

    return Scaffold(
      appBar: modalSheetAppBar(
        context,
        title: 'Novo agendamento',
        actionLabel: 'Confirmar',
        onAction: _formValido ? _confirmar : null,
        onCancel: () => Navigator.of(context).pop(),
        loading: _salvando,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const SectionLabel('Pet'),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: pets.map((pet) {
                final selecionado = _petSelecionado?.id == pet.id;
                return _AvatarOption(
                  label: pet.name,
                  icon: Icons.pets_rounded,
                  selected: selecionado,
                  onTap: () {
                    Haptics.selection();
                    setState(() => _petSelecionado = pet);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 26),
            const SectionLabel('Serviço'),
            ...servicos.map((servico) {
              final selecionado = _servicoSelecionado?.id == servico.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CustomCard(
                  selected: selecionado,
                  blur: false,
                  onTap: () {
                    Haptics.selection();
                    setState(() => _servicoSelecionado = servico);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(servico.nome, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text('${servico.duracaoFormatada} · R\$ ${servico.preco.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      Icon(
                        selecionado ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: selecionado ? AppColors.primary : AppColors.border,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),
            const SectionLabel('Profissional'),
            if (funcionariosProvider.carregando)
              const Shimmer(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Skeleton(width: 100, height: 36, borderRadius: BorderRadius.all(Radius.circular(999))),
                    Skeleton(width: 84, height: 36, borderRadius: BorderRadius.all(Radius.circular(999))),
                    Skeleton(width: 92, height: 36, borderRadius: BorderRadius.all(Radius.circular(999))),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: funcionarios.map((funcionario) {
                  final selecionado = _funcionarioSelecionado?.id == funcionario.id;
                  return _ChoicePill(
                    label: funcionario.nome,
                    selected: selecionado,
                    onTap: () {
                      Haptics.selection();
                      setState(() => _funcionarioSelecionado = funcionario);
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 26),
            const SectionLabel('Data e horário'),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    onTap: _selecionarData,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(height: 10),
                        Text('Data', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text(
                          _dataSelecionada == null ? 'Selecionar' : DateFormatters.dataCurta(_dataSelecionada!),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    onTap: _selecionarHora,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(height: 10),
                        Text('Horário', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text(
                          _horaSelecionada == null ? 'Selecionar' : _horaSelecionada!.format(context),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Opção com avatar redondo — usada para escolher o pet do agendamento, com
/// o mesmo aro colorido e selo de check das listas de seleção do iOS.
class _AvatarOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: false,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceSecondary,
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 2.4,
                    ),
                  ),
                  child: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
                ),
                if (selected)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                      ),
                      child: Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cápsula de escolha simples (sem avatar) — usada para o profissional.
class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 1.4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
