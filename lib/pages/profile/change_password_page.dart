import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/feedback.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Alteração de senha do tutor.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().changePassword(
        currentPassword: _current.text,
        newPassword: _password.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop('Senha alterada com sucesso!');
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
      appBar: AppBar(title: const Text('Alterar senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppCard(
                  color: AppColors.lightBlue.withValues(alpha: 0.10),
                  elevated: false,
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.blue,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Escolha uma senha com pelo menos 6 caracteres, '
                          'combinando letras e números.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.text, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _current,
                  label: 'Senha atual',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  validator: (String? value) =>
                      Validators.required(value, field: 'A senha atual'),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _password,
                  label: 'Nova senha',
                  icon: Icons.lock_reset_rounded,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                ),
                const SizedBox(height: 12),
                _PasswordStrength(password: _password.text),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _confirm,
                  label: 'Confirmar nova senha',
                  icon: Icons.check_circle_outline_rounded,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: (String? value) =>
                      Validators.confirmPassword(value, _password.text),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Alterar senha',
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

/// Indicador visual de força da nova senha.
class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.password});

  final String password;

  int get _score {
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[A-Za-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    const List<String> labels = <String>[
      'Muito fraca',
      'Fraca',
      'Boa',
      'Forte',
      'Excelente',
    ];
    const List<Color> colors = <Color>[
      AppColors.danger,
      AppColors.warning,
      AppColors.lightBlue,
      AppColors.success,
      AppColors.success,
    ];
    final int score = _score;

    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: List<Widget>.generate(4, (int index) {
              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: index < score ? colors[score] : AppColors.divider,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          labels[score],
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors[score],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
