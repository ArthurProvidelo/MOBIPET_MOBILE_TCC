import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet.dart';
import '../../services/appointment_repository.dart';
import '../../services/pet_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import '../../utils/input_masks.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/primary_button.dart';

/// Cadastro (novo pet) e edição de pet — o mesmo formulário atende
/// às duas telas.
class PetFormPage extends StatefulWidget {
  const PetFormPage({super.key, this.pet});

  final Pet? pet;

  bool get isEditing => pet != null;

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.pet?.name ?? '',
  );
  late final TextEditingController _breed = TextEditingController(
    text: widget.pet?.breed ?? '',
  );
  late final TextEditingController _weight = TextEditingController(
    text: widget.pet == null
        ? ''
        : widget.pet!.weightKg.toStringAsFixed(1).replaceAll('.', ','),
  );
  late final TextEditingController _rfid = TextEditingController(
    text: widget.pet?.rfidTag ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.pet?.notes ?? '',
  );
  late final TextEditingController _birth = TextEditingController(
    text: widget.pet == null ? '' : Formatters.date(widget.pet!.birthDate),
  );

  late DateTime? _birthDate = widget.pet?.birthDate;
  late PetSpecies _species = widget.pet?.species ?? PetSpecies.dog;
  late PetSize _size = widget.pet?.size ?? PetSize.medium;
  late String _gender = widget.pet?.gender ?? 'Macho';
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _weight.dispose();
    _rfid.dispose();
    _notes.dispose();
    _birth.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 2, now.month, now.day),
      firstDate: DateTime(now.year - 30),
      lastDate: now,
      helpText: 'Data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Selecionar',
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _birth.text = Formatters.date(picked);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      AppFeedback.error(context, 'Informe a data de nascimento do pet.');
      return;
    }
    setState(() => _loading = true);
    final PetRepository repository = context.read<PetRepository>();
    final Pet pet = Pet(
      id: widget.pet?.id ?? repository.nextId(),
      name: _name.text.trim(),
      breed: _breed.text.trim(),
      birthDate: _birthDate!,
      species: _species,
      size: _size,
      weightKg: double.parse(_weight.text.replaceAll(',', '.')),
      gender: _gender,
      rfidTag: _rfid.text.trim().isEmpty ? null : _rfid.text.trim(),
      photoAsset: widget.pet?.photoAsset,
      notes: _notes.text.trim(),
    );

    if (widget.isEditing) {
      await repository.update(pet);
    } else {
      await repository.create(pet);
    }
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pop(
      widget.isEditing
          ? '${pet.name} foi atualizado com sucesso!'
          : '${pet.name} foi cadastrado com sucesso!',
    );
  }

  Future<void> _delete() async {
    final Pet pet = widget.pet!;
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Excluir ${pet.name}?',
      message:
          'Todos os agendamentos vinculados a ${pet.name} também serão '
          'removidos. Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() => _loading = true);
    context.read<AppointmentRepository>().removeByPet(pet.id);
    await context.read<PetRepository>().delete(pet.id);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pop('${pet.name} foi removido dos seus pets.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar pet' : 'Cadastrar pet'),
        actions: <Widget>[
          if (widget.isEditing)
            IconButton(
              tooltip: 'Excluir pet',
              onPressed: _loading ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.danger,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(child: _photoPicker()),
                const SizedBox(height: 26),
                AppTextField(
                  controller: _name,
                  label: 'Nome do pet',
                  hint: 'Ex.: Thor',
                  icon: Icons.pets_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (String? value) =>
                      Validators.required(value, field: 'O nome'),
                ),
                const SizedBox(height: 18),
                _speciesSelector(),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _breed,
                  label: 'Raça',
                  hint: 'Ex.: Golden Retriever',
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (String? value) =>
                      Validators.required(value, field: 'A raça'),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: AppTextField(
                        controller: _birth,
                        label: 'Nascimento',
                        hint: 'dd/mm/aaaa',
                        icon: Icons.cake_outlined,
                        readOnly: true,
                        onTap: _pickBirthDate,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppTextField(
                        controller: _weight,
                        label: 'Peso (kg)',
                        hint: 'Ex.: 12,5',
                        icon: Icons.monitor_weight_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: InputMasks.decimal,
                        validator: Validators.weight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _sizeSelector(),
                const SizedBox(height: 18),
                _genderSelector(),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _rfid,
                  label: 'Cartão RFID (opcional)',
                  hint: 'Ex.: RF-0A17C4',
                  icon: Icons.nfc_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'O cartão é entregue no pet shop e vinculado ao pet no '
                    'momento do check-in.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _notes,
                  label: 'Observações (opcional)',
                  hint: 'Cuidados especiais, alergias, preferências...',
                  icon: Icons.sticky_note_2_outlined,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: widget.isEditing
                      ? 'Salvar alterações'
                      : 'Cadastrar pet',
                  loading: _loading,
                  icon: widget.isEditing
                      ? Icons.check_rounded
                      : Icons.add_rounded,
                  onPressed: _save,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoPicker() {
    final Pet preview = Pet(
      id: widget.pet?.id ?? 'novo',
      name: _name.text.isEmpty ? '?' : _name.text,
      breed: _breed.text,
      birthDate: _birthDate ?? DateTime.now(),
      species: _species,
      size: _size,
      weightKg: 0,
      photoAsset: widget.pet?.photoAsset,
    );
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            PetAvatar(pet: preview, size: 110),
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: AppColors.orange,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => AppFeedback.info(
                    context,
                    'Upload de foto disponível na versão integrada à API.',
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 19,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Adicionar foto', style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }

  Widget _speciesSelector() {
    return _FieldGroup(
      label: 'Espécie',
      child: Wrap(
        spacing: 10,
        children: PetSpecies.values.map((PetSpecies species) {
          return ChoiceChip(
            label: Text(species.label),
            selected: _species == species,
            showCheckmark: false,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: _species == species ? AppColors.white : AppColors.text,
            ),
            avatar: Icon(
              species == PetSpecies.cat
                  ? Icons.emoji_nature_rounded
                  : Icons.pets_rounded,
              size: 17,
              color: _species == species ? AppColors.white : AppColors.blue,
            ),
            onSelected: (_) => setState(() => _species = species),
          );
        }).toList(),
      ),
    );
  }

  Widget _sizeSelector() {
    return _FieldGroup(
      label: 'Porte',
      child: Row(
        children: PetSize.values.map((PetSize size) {
          final bool selected = _size == size;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: size == PetSize.large ? 0 : 10),
              child: AppCard(
                elevated: false,
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: selected ? AppColors.blue : AppColors.white,
                border: Border.all(
                  color: selected ? AppColors.blue : AppColors.divider,
                ),
                onTap: () => setState(() => _size = size),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.straighten_rounded,
                      size: 19,
                      color: selected ? AppColors.white : AppColors.blue,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      size.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.white : AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _genderSelector() {
    const List<String> options = <String>['Macho', 'Fêmea'];
    return _FieldGroup(
      label: 'Sexo',
      child: Row(
        children: options.map((String option) {
          final bool selected = _gender == option;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: option == options.last ? 0 : 10),
              child: AppCard(
                elevated: false,
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: selected ? AppColors.lightBlue : AppColors.white,
                border: Border.all(
                  color: selected ? AppColors.lightBlue : AppColors.divider,
                ),
                onTap: () => setState(() => _gender = option),
                child: Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.white : AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FieldGroup extends StatelessWidget {
  const _FieldGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
