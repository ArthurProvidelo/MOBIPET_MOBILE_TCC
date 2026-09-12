import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/primary_button.dart';

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({super.key});

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    final sucesso = await appState.alterarSenha(
      senhaAtual: _senhaAtualController.text,
      novaSenha: _novaSenhaController.text,
    );
    if (!mounted) return;
    if (sucesso) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.erro ?? 'Erro ao alterar senha')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final salvando = context.watch<AppState>().carregando;

    return Scaffold(
      appBar: AppBar(title: const Text('Alterar senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(
                  child: AppTextField(
                    label: 'Senha atual',
                    controller: _senhaAtualController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: Validators.senha,
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: AppTextField(
                    label: 'Nova senha',
                    controller: _novaSenhaController,
                    obscureText: true,
                    prefixIcon: Icons.lock_reset_rounded,
                    validator: Validators.senha,
                    helperText:
                        'Use ao menos 6 caracteres, combinando letras maiúsculas, minúsculas, números e símbolos.',
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: AppTextField(
                    label: 'Confirmar nova senha',
                    controller: _confirmarSenhaController,
                    obscureText: true,
                    prefixIcon: Icons.lock_reset_rounded,
                    validator: (v) => Validators.confirmarSenha(v, _novaSenhaController.text),
                    textInputAction: TextInputAction.done,
                    onSubmitted: _salvar,
                  ),
                ),
                const SizedBox(height: 28),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  child: PrimaryButton(label: 'Salvar nova senha', onPressed: _salvar, loading: salvando),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
