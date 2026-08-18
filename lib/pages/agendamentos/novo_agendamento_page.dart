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
import '../../utils/date_formatters.dart';
import '../../widgets/primary_button.dart';

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
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? agora,
      firstDate: agora,
      lastDate: agora.add(const Duration(days: 90)),
    );
    if (data != null) setState(() => _dataSelecionada = data);
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento realizado com sucesso!')),
      );
    } catch (_) {
      if (!mounted) return;
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
    final funcionarios = context.watch<FuncionariosProvider>().funcionarios;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo agendamento')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text('Selecione o pet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: pets.map((pet) {
                final selecionado = _petSelecionado?.id == pet.id;
                return ChoiceChip(
                  avatar: const CircleAvatar(child: Icon(Icons.pets_rounded, size: 16)),
                  label: Text(pet.name),
                  selected: selecionado,
                  onSelected: (_) => setState(() => _petSelecionado = pet),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text('Selecione o serviço', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...servicos.map((servico) {
              final selecionado = _servicoSelecionado?.id == servico.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _servicoSelecionado = servico),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selecionado ? AppColors.primary.withValues(alpha: 0.08) : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selecionado ? AppColors.primary : AppColors.border, width: selecionado ? 1.6 : 1),
                    ),
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
                ),
              );
            }),
            const SizedBox(height: 28),
            Text('Selecione o profissional', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: funcionarios.map((funcionario) {
                final selecionado = _funcionarioSelecionado?.id == funcionario.id;
                return ChoiceChip(
                  label: Text(funcionario.nome),
                  selected: selecionado,
                  onSelected: (_) => setState(() => _funcionarioSelecionado = funcionario),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text('Data e horário', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selecionarData,
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(_dataSelecionada == null ? 'Data' : DateFormatters.dataCurta(_dataSelecionada!)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selecionarHora,
                    icon: const Icon(Icons.access_time_rounded, size: 18),
                    label: Text(_horaSelecionada == null ? 'Horário' : _horaSelecionada!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Confirmar agendamento',
              onPressed: _formValido ? _confirmar : null,
              loading: _salvando,
            ),
          ],
        ),
      ),
    );
  }
}
