import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/feedback.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Tela de recuperação de senha.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().sendPasswordRecovery(_email.text);
      if (!mounted) return;
      setState(() => _sent = true);
      AppFeedback.success(context, 'Enviamos as instruções para seu e-mail.');
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
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _sent ? _successState(context) : _formState(context),
          ),
        ),
      ),
    );
  }

  Widget _formState(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey<String>('form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 42,
                color: AppColors.blue,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Esqueceu sua senha?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Informe o e-mail cadastrado e enviaremos um link para você criar '
            'uma nova senha.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          AppTextField(
            controller: _email,
            label: 'E-mail cadastrado',
            hint: 'seuemail@exemplo.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            label: 'Enviar instruções',
            loading: _loading,
            icon: Icons.send_rounded,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _successState(BuildContext context) {
    return Column(
      key: const ValueKey<String>('success'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 46,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'E-mail enviado!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(
          'Enviamos as instruções de recuperação para\n${_email.text.trim()}. '
          'Verifique também a caixa de spam.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Voltar para o login',
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _sent = false),
          child: const Text('Não recebi o e-mail'),
        ),
      ],
    );
  }
}
