import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/viacep_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/haptics.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _cpfController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _cepController;
  late final TextEditingController _enderecoController;

  final _picker = ImagePicker();
  final _viaCepService = ViaCepService();
  bool _buscandoCep = false;

  @override
  void initState() {
    super.initState();
    final usuario = context.read<AppState>().usuario;
    _nomeController = TextEditingController(text: usuario?.nome ?? '');
    _cpfController = TextEditingController(text: Mascaras.cpf(usuario?.cpf ?? ''));
    _emailController = TextEditingController(text: usuario?.email ?? '');
    _telefoneController =
        TextEditingController(text: Mascaras.telefone(usuario?.telefone ?? ''));
    _cepController = TextEditingController(text: Mascaras.cep(usuario?.cep ?? ''));
    _enderecoController = TextEditingController(text: usuario?.endereco ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final digits = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return;
    setState(() => _buscandoCep = true);
    try {
      final endereco = await _viaCepService.buscar(digits);
      if (!mounted) return;
      if (endereco == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CEP não encontrado')),
        );
        return;
      }
      _enderecoController.text = endereco.enderecoFormatado;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível buscar o CEP')),
      );
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  Future<void> _escolherFoto(ImageSource source) async {
    final origem = source == ImageSource.camera ? 'a câmera' : 'a galeria';
    XFile? imagem;
    try {
      imagem = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
    } catch (_) {
      if (!mounted) return;
      Haptics.error();
      _mostrarMensagem(
        'Não foi possível acessar $origem. Verifique as permissões do app '
        'nas configurações do celular.',
      );
      return;
    }
    // Seleção cancelada pelo usuário.
    if (imagem == null || !mounted) return;

    final ok = await context.read<AppState>().definirFotoPerfil(imagem);
    if (!mounted) return;
    if (ok) {
      Haptics.success();
    } else {
      Haptics.error();
    }
    _mostrarMensagem(
      ok
          ? 'Foto de perfil atualizada!'
          : 'Não foi possível salvar a foto neste dispositivo.',
    );
  }

  Future<void> _removerFoto() async {
    final ok = await context.read<AppState>().definirFotoPerfil(null);
    if (!mounted) return;
    if (ok) {
      Haptics.medium();
      _mostrarMensagem('Foto de perfil removida.');
    }
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  void _abrirOpcoesFoto() {
    final temFoto = context.read<AppState>().fotoPerfil != null;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _escolherFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _escolherFoto(ImageSource.gallery);
              },
            ),
            if (temFoto)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger),
                title: const Text('Remover foto',
                    style: TextStyle(color: AppColors.danger)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _removerFoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    final sucesso = await appState.atualizarPerfil(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      telefone: _telefoneController.text.trim(),
      cep: _cepController.text.trim(),
      endereco: _enderecoController.text.trim(),
    );
    if (!mounted) return;
    if (sucesso) {
      Haptics.success();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } else {
      Haptics.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.erro ?? 'Erro ao atualizar perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final salvando = appState.carregando;
    final foto = appState.fotoPerfil;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (foto == null) ...[
                  const Center(
                    child: _BalaoDeFala(
                      'Você ainda não tem uma foto de perfil. Toque na imagem '
                      'para adicionar uma.',
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Center(child: _AvatarEditavel(foto: foto, onTap: _abrirOpcoesFoto)),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _abrirOpcoesFoto,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: Text(foto == null ? 'Adicionar foto' : 'Alterar foto'),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Nome completo',
                  controller: _nomeController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.nome,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'CPF',
                  controller: _cpfController,
                  readOnly: true,
                  prefixIcon: Icons.badge_outlined,
                  suffixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.textSecondary, size: 20),
                  helperText: 'O CPF não pode ser alterado.',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'E-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Telefone',
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [TelefoneInputFormatter()],
                  prefixIcon: Icons.phone_outlined,
                  validator: Validators.telefone,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'CEP',
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CepInputFormatter()],
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => Validators.obrigatorio(v, 'Informe o CEP'),
                  onChanged: (v) {
                    if (v.replaceAll(RegExp(r'\D'), '').length == 8) {
                      _buscarCep();
                    }
                  },
                  suffixIcon: _buscandoCep
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search_rounded),
                          onPressed: _buscarCep,
                        ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Endereço',
                  controller: _enderecoController,
                  prefixIcon: Icons.home_outlined,
                  validator: (v) => Validators.obrigatorio(v, 'Informe o endereço'),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Salvar alterações',
                  onPressed: _salvar,
                  loading: salvando,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Balão de fala exibido acima do avatar quando ainda não há foto de perfil.
class _BalaoDeFala extends StatelessWidget {
  final String mensagem;

  const _BalaoDeFala(this.mensagem);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  mensagem,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        CustomPaint(size: const Size(18, 9), painter: _RaboBalao()),
      ],
    );
  }
}

class _RaboBalao extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AvatarEditavel extends StatelessWidget {
  final File? foto;
  final VoidCallback onTap;

  const _AvatarEditavel({required this.foto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.background,
            backgroundImage: foto != null ? FileImage(foto!) : null,
            child: foto == null
                ? const Icon(Icons.person_outline_rounded,
                    size: 46, color: AppColors.primary)
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 16, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
