import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agendamento.dart';
import '../../models/pet.dart';
import '../../models/servico.dart';
import '../../services/mock_data.dart';
import '../../state/agendamentos_provider.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class NovoAgendamentoPage extends StatefulWidget {
  final String? petIdPreSelecionado;

  const NovoAgendamentoPage({super.key, this.petIdPreSelecionado});

  @override
  State<NovoAgendamentoPage> createState() => _NovoAgendamentoPageState();
}

class _NovoAgendamentoPageState extends State<NovoAgendamentoPage> {
  int _currentStep = 0;
  Pet? _petSelecionado;
  Servico? _servicoSelecionado;
  DateTime _dataSelecionada = DateTime.now().add(const Duration(days: 1));
  String? _horarioSelecionado;
  bool _salvando = false;

  static const _horarios = ['09:00', '10:30', '13:00', '14:30', '16:00'];

  @override
  void initState() {
    super.initState();
    if (widget.petIdPreSelecionado != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pet = context.read<PetsProvider>().porId(widget.petIdPreSelecionado!);
        if (pet != null) setState(() => _petSelecionado = pet);
      });
    }
  }

  bool get _canAdvance {
    switch (_currentStep) {
      case 0:
        return _petSelecionado != null;
      case 1:
        return _servicoSelecionado != null;
      case 2:
        return _horarioSelecionado != null;
      default:
        return true;
    }
  }

  Future<void> _confirmar() async {
    setState(() => _salvando = true);
    final dataHora = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      int.parse(_horarioSelecionado!.split(':')[0]),
      int.parse(_horarioSelecionado!.split(':')[1]),
    );
    await context.read<AgendamentosProvider>().criar(
          Agendamento(
            id: 'a_${DateTime.now().millisecondsSinceEpoch}',
            petId: _petSelecionado!.id,
            servicoId: _servicoSelecionado!.id,
            dateTime: dataHora,
            status: StatusAgendamento.agendado,
          ),
        );
    if (!mounted) return;
    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agendamento confirmado!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Agendamento')),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentStep + 1) / 4),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStepPet(),
                _buildStepServico(),
                _buildStepData(),
                _buildStepConfirmar(),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Voltar'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: _currentStep == 3 ? 'Confirmar' : 'Próximo',
                      loading: _salvando,
                      onPressed: !_canAdvance
                          ? null
                          : () {
                              if (_currentStep < 3) {
                                setState(() => _currentStep++);
                              } else {
                                _confirmar();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPet() {
    final pets = context.watch<PetsProvider>().pets;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Para qual pet é o agendamento?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        for (final pet in pets) _buildSelectableTile(
          selected: _petSelecionado?.id == pet.id,
          leading: CircleAvatar(backgroundImage: NetworkImage(pet.imageUrl)),
          title: pet.name,
          subtitle: pet.breed,
          onTap: () => setState(() => _petSelecionado = pet),
        ),
      ],
    );
  }

  Widget _buildStepServico() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Escolha o serviço', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        for (final servico in MockData.servicos)
          _buildSelectableTile(
            selected: _servicoSelecionado?.id == servico.id,
            leading: Icon(servico.icone, color: AppColors.primary),
            title: servico.nome,
            subtitle: 'R\$ ${servico.preco.toStringAsFixed(0)} · ${servico.duracaoEstimada.inMinutes} min',
            onTap: () => setState(() => _servicoSelecionado = servico),
          ),
      ],
    );
  }

  Widget _buildStepData() {
    return Column(
      children: [
        CalendarDatePicker(
          initialDate: _dataSelecionada,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 60)),
          onDateChanged: (date) => setState(() => _dataSelecionada = date),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text('Horários disponíveis', style: TextStyle(fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _horarios.map((horario) {
              final selecionado = _horarioSelecionado == horario;
              return ChoiceChip(
                label: Text(horario),
                selected: selecionado,
                onSelected: (_) => setState(() => _horarioSelecionado = horario),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStepConfirmar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo do Agendamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          _summaryRow('Pet:', _petSelecionado?.name ?? ''),
          _summaryRow('Serviço:', _servicoSelecionado?.nome ?? ''),
          _summaryRow('Data:', '${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}'),
          _summaryRow('Horário:', _horarioSelecionado ?? ''),
        ],
      ),
    );
  }

  Widget _buildSelectableTile({
    required bool selected,
    required Widget leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: leading,
        title: Text(title, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: selected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _summaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
