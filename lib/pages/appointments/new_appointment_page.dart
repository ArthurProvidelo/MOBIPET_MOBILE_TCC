import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet.dart';
import '../../models/pet_service.dart';
import '../../services/appointment_repository.dart';
import '../../services/pet_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/service_card.dart';

/// Novo agendamento: seleção de pet, serviço, data e horário.
class NewAppointmentPage extends StatefulWidget {
  const NewAppointmentPage({super.key, this.initialPetId});

  final String? initialPetId;

  @override
  State<NewAppointmentPage> createState() => _NewAppointmentPageState();
}

class _NewAppointmentPageState extends State<NewAppointmentPage> {
  final TextEditingController _notes = TextEditingController();
  late String? _petId = widget.initialPetId;
  String? _serviceId;
  DateTime _date = _firstAvailableDay();
  String? _time;
  bool _loading = false;

  static DateTime _firstAvailableDay() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return now.hour >= 17 ? today.add(const Duration(days: 1)) : today;
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  bool get _isValid => _petId != null && _serviceId != null && _time != null;

  Future<void> _submit() async {
    if (!_isValid) {
      AppFeedback.error(context, 'Selecione pet, serviço, data e horário.');
      return;
    }
    final AppointmentRepository repository = context
        .read<AppointmentRepository>();
    final Pet? pet = context.read<PetRepository>().byId(_petId);
    final PetService? service = repository.serviceById(_serviceId);
    final List<String> parts = _time!.split(':');
    final DateTime scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Confirmar agendamento?',
      message:
          '${service?.name} para ${pet?.name}\n'
          '${Formatters.weekday(scheduledAt)}, '
          '${Formatters.dateLong(scheduledAt)} às ${Formatters.time(scheduledAt)}.',
      confirmLabel: 'Confirmar',
      icon: Icons.event_available_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _loading = true);
    await repository.create(
      petId: _petId!,
      serviceId: _serviceId!,
      dateTime: scheduledAt,
      notes: _notes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pop(
      '${service?.name} agendado para ${pet?.name} em '
      '${Formatters.date(scheduledAt)} às ${Formatters.time(scheduledAt)}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Pet> pets = context.watch<PetRepository>().pets;
    final AppointmentRepository repository = context
        .watch<AppointmentRepository>();
    final List<String> times = repository.availableTimesFor(_date);
    final PetService? service = repository.serviceById(_serviceId);

    if (pets.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Novo agendamento')),
        body: EmptyState(
          icon: Icons.pets_rounded,
          title: 'Cadastre um pet primeiro',
          message:
              'Para agendar um serviço é preciso ter ao menos um pet '
              'cadastrado na sua conta.',
          actionLabel: 'Voltar',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Novo agendamento')),
      bottomNavigationBar: _BottomBar(
        service: service,
        enabled: _isValid,
        loading: _loading,
        onSubmit: _submit,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: <Widget>[
            _StepLabel(number: 1, label: 'Escolha o pet'),
            const SizedBox(height: 12),
            SizedBox(
              height: 122,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final Pet pet = pets[index];
                  final bool selected = pet.id == _petId;
                  return SizedBox(
                    width: 108,
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      border: Border.all(
                        color: selected ? AppColors.blue : Colors.transparent,
                        width: 1.8,
                      ),
                      onTap: () => setState(() => _petId = pet.id),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          PetAvatar(pet: pet, size: 52),
                          const SizedBox(height: 8),
                          Text(
                            pet.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            pet.breed,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            _StepLabel(number: 2, label: 'Escolha o serviço'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: repository.services
                  .map(
                    (PetService item) => ServiceCard(
                      service: item,
                      dense: true,
                      selected: item.id == _serviceId,
                      onTap: () => setState(() => _serviceId = item.id),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 26),
            _StepLabel(number: 3, label: 'Data e horário'),
            const SizedBox(height: 12),
            _DateSelector(
              selected: _date,
              onSelected: (DateTime date) => setState(() {
                _date = date;
                _time = null;
              }),
            ),
            const SizedBox(height: 16),
            if (times.isEmpty)
              AppCard(
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Não há mais horários disponíveis nesta data. '
                        'Escolha outro dia.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: times.map((String time) {
                  final bool selected = time == _time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: selected,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.white : AppColors.text,
                    ),
                    onSelected: (_) => setState(() => _time = time),
                  );
                }).toList(),
              ),
            const SizedBox(height: 26),
            _StepLabel(number: 4, label: 'Observações (opcional)'),
            const SizedBox(height: 12),
            AppTextField(
              controller: _notes,
              label: 'Alguma orientação para a equipe?',
              hint: 'Ex.: usar shampoo hipoalergênico',
              icon: Icons.sticky_note_2_outlined,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            gradient: AppColors.brandGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.selected, required this.onSelected});

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final DateTime date = today.add(Duration(days: index));
          final bool isSelected =
              date.day == selected.day &&
              date.month == selected.month &&
              date.year == selected.year;
          return SizedBox(
            width: 66,
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: isSelected ? AppColors.blue : AppColors.white,
              border: Border.all(
                color: isSelected ? AppColors.blue : AppColors.divider,
              ),
              elevated: isSelected,
              onTap: () => onSelected(date),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    Formatters.weekday(date).substring(0, 3).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.9)
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}'.padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.white : AppColors.text,
                    ),
                  ),
                  Text(
                    Formatters.dateShort(date).split(' ').last,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.9)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.service,
    required this.enabled,
    required this.loading,
    required this.onSubmit,
  });

  final PetService? service;
  final bool enabled;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          if (service != null) ...<Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Total', style: Theme.of(context).textTheme.labelSmall),
                Text(
                  Formatters.currency(service!.price),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.blue),
                ),
              ],
            ),
            const SizedBox(width: 18),
          ],
          Expanded(
            child: PrimaryButton(
              label: 'Confirmar agendamento',
              loading: loading,
              icon: Icons.check_rounded,
              onPressed: enabled ? onSubmit : null,
            ),
          ),
        ],
      ),
    );
  }
}
