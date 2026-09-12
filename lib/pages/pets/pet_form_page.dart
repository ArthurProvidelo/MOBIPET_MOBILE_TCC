import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/cupertino_pickers.dart';
import '../../utils/haptics.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/glass_sheet.dart';
import '../../widgets/modal_sheet_appbar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/round_icon.dart';
import '../../widgets/section_label.dart';
import '../../widgets/species_icon.dart';

const _especies = <String>['Cão', 'Gato', 'Outro'];
const _portes = <_PorteOpcao>[
  _PorteOpcao('Pequeno', 12),
  _PorteOpcao('Médio', 18),
  _PorteOpcao('Grande', 24),
];

class _PorteOpcao {
  final String label;
  final double tamanho;
  const _PorteOpcao(this.label, this.tamanho);
}

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
  final _picker = ImagePicker();
  late final TextEditingController _nomeController;
  late final TextEditingController _racaController;
  DateTime? _nascimento;
  String _especie = _especies.first;
  String _porte = _portes.first.label;
  bool _salvando = false;
  String? _erro;

  /// Foto já salva do pet (edição) — ver [PetsProvider.fotoDe].
  File? _fotoAtual;

  /// Foto recém-escolhida nesta sessão, ainda não persistida (cadastro: só
  /// vira arquivo de verdade depois que o pet existe e ganha um id).
  XFile? _novaFoto;

  /// Bytes de [_novaFoto], para pré-visualizar sem depender de `dart:io`
  /// (que não funciona na web) antes de haver um arquivo de verdade.
  Uint8List? _novaFotoBytes;

  Pet? get _petOriginal =>
      widget.isEdicao ? context.read<PetsProvider>().porId(widget.petId!) : null;

  ImageProvider? get _imagemAtual {
    if (_novaFotoBytes != null) return MemoryImage(_novaFotoBytes!);
    if (_fotoAtual != null) return FileImage(_fotoAtual!);
    return null;
  }

  @override
  void initState() {
    super.initState();
    final pet = _petOriginal;
    _nomeController = TextEditingController(text: pet?.name ?? '');
    _racaController = TextEditingController(text: pet?.breed ?? '');
    _especie = pet != null && _especies.contains(pet.especie) ? pet.especie : _especies.first;
    _porte = pet != null && _portes.any((p) => p.label == pet.porte)
        ? pet.porte
        : _portes.first.label;
    _nascimento = pet != null ? DateTime.tryParse(pet.birthDate) : null;
    if (widget.isEdicao) {
      _fotoAtual = context.read<PetsProvider>().fotoDe(widget.petId!);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _racaController.dispose();
    super.dispose();
  }

  void _abrirOpcoesFotoPet() {
    final temFoto = _imagemAtual != null;
    showGlassSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Foto do pet', style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          ListTile(
            leading: const RoundIcon(icon: Icons.photo_camera_outlined),
            title: const Text('Tirar foto'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              _escolherFotoPet(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const RoundIcon(icon: Icons.photo_library_outlined),
            title: const Text('Escolher da galeria'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              _escolherFotoPet(ImageSource.gallery);
            },
          ),
          if (temFoto)
            ListTile(
              leading: RoundIcon(icon: Icons.delete_outline_rounded, color: AppColors.danger),
              title: Text('Remover foto', style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _removerFotoPet();
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _escolherFotoPet(ImageSource source) async {
    XFile? imagem;
    try {
      imagem = await _picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    } catch (_) {
      if (!mounted) return;
      Haptics.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível acessar a foto. Verifique as permissões do app.')),
      );
      return;
    }
    if (imagem == null || !mounted) return;

    if (widget.isEdicao) {
      final ok = await context.read<PetsProvider>().definirFoto(widget.petId!, imagem);
      if (!mounted) return;
      if (ok) {
        Haptics.success();
        setState(() {
          _novaFoto = null;
          _novaFotoBytes = null;
          _fotoAtual = context.read<PetsProvider>().fotoDe(widget.petId!);
        });
      } else {
        Haptics.error();
      }
    } else {
      final bytes = await imagem.readAsBytes();
      if (!mounted) return;
      Haptics.success();
      setState(() {
        _novaFoto = imagem;
        _novaFotoBytes = bytes;
      });
    }
  }

  Future<void> _removerFotoPet() async {
    if (widget.isEdicao) {
      await context.read<PetsProvider>().definirFoto(widget.petId!, null);
      if (!mounted) return;
    }
    Haptics.medium();
    setState(() {
      _novaFoto = null;
      _novaFotoBytes = null;
      _fotoAtual = null;
    });
  }

  Future<void> _selecionarNascimento() async {
    final agora = DateTime.now();
    Haptics.selection();
    final data = await showAppDatePicker(
      context,
      initialDate: _nascimento ?? DateTime(agora.year - 1),
      minimumDate: DateTime(agora.year - 30),
      maximumDate: agora,
    );
    if (data != null) setState(() => _nascimento = data);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _nascimento == null) {
      if (_nascimento == null) setState(() => _erro = 'Informe a data de nascimento');
      Haptics.error();
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
        final criado = await provider.adicionar(pet);
        if (_novaFoto != null) {
          await provider.definirFoto(criado.id, _novaFoto);
        }
      }
      if (!mounted) return;
      Haptics.success();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdicao ? 'Pet atualizado com sucesso!' : 'Pet cadastrado com sucesso!')),
      );
    } catch (_) {
      if (!mounted) return;
      Haptics.error();
      setState(() => _erro = 'Não foi possível salvar o pet. Tente novamente.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataFormatada = _nascimento == null
        ? null
        : '${_nascimento!.day.toString().padLeft(2, '0')}/${_nascimento!.month.toString().padLeft(2, '0')}/${_nascimento!.year}';

    return Scaffold(
      appBar: modalSheetAppBar(
        context,
        title: widget.isEdicao ? 'Editar pet' : 'Novo pet',
        actionLabel: widget.isEdicao ? 'Salvar' : 'Adicionar',
        onAction: _salvar,
        onCancel: () => Navigator.of(context).pop(),
        loading: _salvando,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _PetAvatarEditavel(
                    imagem: _imagemAtual,
                    especie: _especie,
                    onTap: _abrirOpcoesFotoPet,
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: _abrirOpcoesFotoPet,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: Text(_imagemAtual == null ? 'Adicionar foto' : 'Alterar foto'),
                  ),
                ),
                const SizedBox(height: 12),
                const SectionLabel('Sobre o pet'),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Nome do pet',
                        controller: _nomeController,
                        prefixIcon: Icons.badge_outlined,
                        validator: Validators.nome,
                      ),
                      const SizedBox(height: 18),
                      Text('Espécie', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 10),
                      CupertinoSlidingSegmentedControl<String>(
                        groupValue: _especie,
                        backgroundColor: AppColors.surfaceSecondary,
                        thumbColor: AppColors.surface,
                        padding: const EdgeInsets.all(3),
                        children: {
                          for (final opcao in _especies)
                            opcao: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SpeciesIcon(
                                    especie: opcao,
                                    size: 16,
                                    color: _especie == opcao
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    opcao,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _especie == opcao
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        },
                        onValueChanged: (valor) {
                          if (valor == null) return;
                          Haptics.selection();
                          setState(() => _especie = valor);
                        },
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Raça',
                        controller: _racaController,
                        prefixIcon: Icons.category_outlined,
                        validator: (v) => Validators.obrigatorio(v, 'Informe a raça'),
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionLabel('Porte'),
                CustomCard(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Row(
                    children: _portes
                        .map((opcao) => Expanded(
                              child: _PorteButton(
                                opcao: opcao,
                                selecionado: _porte == opcao.label,
                                onTap: () {
                                  Haptics.selection();
                                  setState(() => _porte = opcao.label);
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                const SectionLabel('Nascimento'),
                CustomCard(
                  onTap: _selecionarNascimento,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Data de nascimento',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        dataFormatada ?? 'Selecionar',
                        style: TextStyle(
                          color: dataFormatada == null ? AppColors.textTertiary : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                if (_erro != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(_erro!, style: TextStyle(color: AppColors.danger)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar do pet no topo do formulário: mostra a foto escolhida, ou o ícone
/// da espécie enquanto não há uma. Tocar abre as opções de foto.
class _PetAvatarEditavel extends StatelessWidget {
  final ImageProvider? imagem;
  final String especie;
  final VoidCallback onTap;

  const _PetAvatarEditavel({required this.imagem, required this.especie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Container(
              key: ValueKey(imagem != null ? 'foto-${imagem.hashCode}' : especie),
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
                image: imagem != null ? DecorationImage(image: imagem!, fit: BoxFit.cover) : null,
              ),
              child: imagem != null ? null : Center(child: SpeciesIcon(especie: especie, size: 42, color: AppColors.primary)),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão de porte: o círculo cresce junto com o tamanho, uma pista visual
/// direta em vez de só o texto ("Pequeno/Médio/Grande" já se vê no tamanho).
class _PorteButton extends StatelessWidget {
  final _PorteOpcao opcao;
  final bool selecionado;
  final VoidCallback onTap;

  const _PorteButton({required this.opcao, required this.selecionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? AppColors.primary : AppColors.textTertiary;
    return Pressable(
      onTap: onTap,
      haptic: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 28,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  width: opcao.tamanho,
                  height: opcao.tamanho,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: cor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              opcao.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
                color: selecionado ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
