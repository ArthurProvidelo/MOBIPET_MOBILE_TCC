import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AppState>().alterarSenha(
          senhaAtual: _senhaAtualController.text,
          novaSenha: _novaSenhaController.text,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha alterada com sucesso')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppState>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Alterar Senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _senhaAtualController,
                  label: 'Senha atual',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => Validators.obrigatorio(v, campo: 'A senha atual'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _novaSenhaController,
                  label: 'Nova senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: Validators.senha,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmarSenhaController,
                  label: 'Confirmar nova senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v != _novaSenhaController.text ? 'As senhas não coincidem' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Alterar senha', onPressed: _submit, loading: isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
