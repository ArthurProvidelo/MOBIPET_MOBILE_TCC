import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../services/mock_data.dart';
import '../../state/pets_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

enum PetFormMode { create, edit }

const _sampleImages = [
  'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=400',
  'https://images.unsplash.com/photo-1591768575198-88dac53fbd0a?auto=format&fit=crop&q=80&w=400',
  'https://images.unsplash.com/photo-1633722715463-d30f4f325e24?auto=format&fit=crop&q=80&w=400',
  'https://images.unsplash.com/photo-1544568100-847a948585b9?auto=format&fit=crop&q=80&w=400',
  'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=400',
];

class PetFormPage extends StatefulWidget {
  final PetFormMode mode;
  final Pet? pet;

  const PetFormPage({super.key, required this.mode, this.pet}) : assert(mode == PetFormMode.create || pet != null);

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _racaController;
  late final TextEditingController _idadeController;
  late final TextEditingController _pesoController;
  late final TextEditingController _nascimentoController;
  late final TextEditingController _notasController;
  late String _sexo;
  late String _imagemSelecionada;
  bool _salvando = false;

  bool get _isEdit => widget.mode == PetFormMode.edit;

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _nomeController = TextEditingController(text: pet?.name ?? '');
    _racaController = TextEditingController(text: pet?.breed ?? '');
    _idadeController = TextEditingController(text: pet?.age ?? '');
    _pesoController = TextEditingController(text: pet != null ? pet.weight.toString() : '');
    _nascimentoController = TextEditingController(text: pet?.birthDate ?? '');
    _notasController = TextEditingController(text: pet?.notes ?? '');
    _sexo = pet?.gender ?? 'Macho';
    _imagemSelecionada = pet?.imageUrl ?? _sampleImages.first;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _racaController.dispose();
    _idadeController.dispose();
    _pesoController.dispose();
    _nascimentoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final petsProvider = context.read<PetsProvider>();
    final pet = Pet(
      id: widget.pet?.id ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
      donoId: MockData.donoId,
      name: _nomeController.text.trim(),
      breed: _racaController.text.trim(),
      age: _idadeController.text.trim(),
      gender: _sexo,
      weight: double.parse(_pesoController.text.replaceAll(',', '.')),
      birthDate: _nascimentoController.text.trim(),
      imageUrl: _imagemSelecionada,
      notes: _notasController.text.trim(),
    );

    if (_isEdit) {
      await petsProvider.atualizar(pet);
    } else {
      await petsProvider.adicionar(pet);
    }

    if (!mounted) return;
    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Alterações salvas com sucesso' : 'Pet cadastrado com sucesso')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar Pet' : 'Cadastro de Pet')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sampleImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final url = _sampleImages[index];
                      final selecionado = url == _imagemSelecionada;
                      return GestureDetector(
                        onTap: () => setState(() => _imagemSelecionada = url),
                        child: CircleAvatar(
                          radius: 34,
                          backgroundColor: selecionado ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          child: CircleAvatar(radius: 30, backgroundImage: NetworkImage(url)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _nomeController,
                  label: 'Nome do pet',
                  prefixIcon: Icons.pets,
                  validator: (v) => Validators.obrigatorio(v, campo: 'O nome'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _racaController,
                  label: 'Raça',
                  prefixIcon: Icons.category_outlined,
                  validator: (v) => Validators.obrigatorio(v, campo: 'A raça'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sexo,
                        decoration: const InputDecoration(labelText: 'Sexo'),
                        items: const [
                          DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                          DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
                        ],
                        onChanged: (value) => setState(() => _sexo = value ?? _sexo),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _pesoController,
                        label: 'Peso (kg)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => Validators.numero(v, campo: 'O peso'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _idadeController,
                        label: 'Idade',
                        hint: 'Ex: 3 anos',
                        validator: (v) => Validators.obrigatorio(v, campo: 'A idade'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _nascimentoController,
                        label: 'Nascimento',
                        hint: 'dd/mm/aaaa',
                        validator: (v) => Validators.obrigatorio(v, campo: 'A data de nascimento'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _notasController,
                  label: 'Observações e cuidados especiais',
                  maxLines: 3,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _isEdit ? 'Salvar alterações' : 'Salvar',
                  onPressed: _submit,
                  loading: _salvando,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
