import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../state/pets_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

const _especies = ['Cão', 'Gato', 'Outro'];
const _portes = ['Pequeno', 'Médio', 'Grande'];

/// Usada tanto para o cadastro quanto para a edição de um pet: quando
/// [petId] é informado, o formulário é pré-preenchido com os dados atuais.
class PetFormPage extends StatefulWidget {
  final String? petId;

  const PetFormPage({super.key, this.petId});

  bool get isEdicao => petId != null;

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _racaController;
  DateTime? _nascimento;
  String _especie = _especies.first;
  String _porte = _portes.first;
  bool _salvando = false;
  String? _erro;

  Pet? get _petOriginal =>
      widget.isEdicao ? context.read<PetsProvider>().porId(widget.petId!) : null;

  @override
  void initState() {
    super.initState();
    final pet = _petOriginal;
    _nomeController = TextEditingController(text: pet?.name ?? '');
    _racaController = TextEditingController(text: pet?.breed ?? '');
    _especie = pet != null && _especies.contains(pet.especie) ? pet.especie : _especies.first;
    _porte = pet != null && _portes.contains(pet.porte) ? pet.porte : _portes.first;
    _nascimento = pet != null ? DateTime.tryParse(pet.birthDate) : null;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _racaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarNascimento() async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: _nascimento ?? DateTime(agora.year - 1),
      firstDate: DateTime(agora.year - 30),
      lastDate: agora,
    );
    if (data != null) setState(() => _nascimento = data);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _nascimento == null) {
      if (_nascimento == null) setState(() => _erro = 'Informe a data de nascimento');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });

    final provider = context.read<PetsProvider>();
    final nascimentoIso =
        '${_nascimento!.year.toString().padLeft(4, '0')}-${_nascimento!.month.toString().padLeft(2, '0')}-${_nascimento!.day.toString().padLeft(2, '0')}';

    final pet = Pet(
      id: widget.petId ?? '',
      donoId: _petOriginal?.donoId ?? '',
      name: _nomeController.text.trim(),
      especie: _especie,
      breed: _racaController.text.trim(),
      porte: _porte,
      birthDate: nascimentoIso,
    );

    try {
      if (widget.isEdicao) {
        await provider.atualizar(pet);
      } else {
        await provider.adicionar(pet);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdicao ? 'Pet atualizado com sucesso!' : 'Pet cadastrado com sucesso!')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível salvar o pet. Tente novamente.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdicao ? 'Editar pet' : 'Cadastrar pet')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Nome do pet',
                  controller: _nomeController,
                  prefixIcon: Icons.pets_outlined,
                  validator: Validators.nome,
                ),
                const SizedBox(height: 16),
                Text('Espécie', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _especies
                      .map((e) => ChoiceChip(
                            label: Text(e),
                            selected: _especie == e,
                            onSelected: (_) => setState(() => _especie = e),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Raça',
                  controller: _racaController,
                  prefixIcon: Icons.category_outlined,
                  validator: (v) => Validators.obrigatorio(v, 'Informe a raça'),
                ),
                const SizedBox(height: 16),
                Text('Porte', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _portes
                      .map((p) => ChoiceChip(
                            label: Text(p),
                            selected: _porte == p,
                            onSelected: (_) => setState(() => _porte = p),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text('Data de nascimento', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _selecionarNascimento,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(
                    _nascimento == null
                        ? 'Selecionar data'
                        : '${_nascimento!.day.toString().padLeft(2, '0')}/${_nascimento!.month.toString().padLeft(2, '0')}/${_nascimento!.year}',
                  ),
                ),
                if (_erro != null) ...[
                  const SizedBox(height: 12),
                  Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 28),
                PrimaryButton(
                  label: widget.isEdicao ? 'Salvar alterações' : 'Cadastrar pet',
                  onPressed: _salvar,
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
