import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/feedback.dart';
import '../../utils/input_masks.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Edição dos dados do tutor.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AppUser? _user = context.read<AuthService>().currentUser;
  late final TextEditingController _name = TextEditingController(
    text: _user?.name ?? '',
  );
  late final TextEditingController _email = TextEditingController(
    text: _user?.email ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: _user?.phone ?? '',
  );
  late final TextEditingController _document = TextEditingController(
    text: _user?.document ?? '',
  );
  late final TextEditingController _address = TextEditingController(
    text: _user?.address ?? '',
  );
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _document.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().updateProfile(
        name: _name.text,
        email: _email.text,
        phone: _phone.text,
        document: _document.text,
        address: _address.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop('Perfil atualizado com sucesso!');
    } on AuthException catch (error) {
      if (!mounted) return;
      AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              gradient: AppColors.brandGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _user?.initials ?? '?',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
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
                                  'Upload de foto disponível na versão '
                                  'integrada à API.',
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.photo_camera_rounded,
                                    size: 18,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Alterar foto',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                AppTextField(
                  controller: _name,
                  label: 'Nome completo',
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: Validators.name,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _email,
                  label: 'E-mail',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _phone,
                  label: 'Telefone',
                  hint: '(00) 00000-0000',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: InputMasks.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _document,
                  label: 'CPF',
                  hint: '000.000.000-00',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: InputMasks.document,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _address,
                  label: 'Endereço',
                  hint: 'Rua, número - cidade/UF',
                  icon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.done,
                  maxLines: 2,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Salvar alterações',
                  icon: Icons.check_rounded,
                  loading: _loading,
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
}
