import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/app_page_route.dart';
import '../../state/app_state.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/primary_button.dart';
import '../main_navigation_page.dart';
import 'criar_conta_page.dart';
import 'recuperar_senha_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    final sucesso = await appState.login(
      email: _emailController.text,
      senha: _senhaController.text,
    );
    if (!mounted) return;
    if (sucesso) {
      Navigator.of(context).pushReplacement(
        AppPageRoute.fade((_) => const MainNavigationPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.erro ?? 'Erro ao entrar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<AppState>().carregando;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 36),
                        const FadeSlideIn(child: _AnimatedLogo()),
                        const SizedBox(height: 22),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 90),
                          child: Text(
                            'Bem-vindo de volta',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: AppColors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 150),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Acompanhe o atendimento do seu pet em tempo real.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.white.withValues(alpha: 0.85),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        Expanded(
                          child: FadeSlideIn(
                            delay: const Duration(milliseconds: 220),
                            offsetY: 40,
                            child: _FormCard(
                              formKey: _formKey,
                              emailController: _emailController,
                              senhaController: _senhaController,
                              carregando: carregando,
                              onEntrar: _entrar,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool carregando;
  final VoidCallback onEntrar;

  const _FormCard({
    required this.formKey,
    required this.emailController,
    required this.senhaController,
    required this.carregando,
    required this.onEntrar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text('Entrar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Use o e-mail cadastrado no MobiPet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'E-mail',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Senha',
              controller: senhaController,
              obscureText: true,
              prefixIcon: Icons.lock_outline_rounded,
              validator: Validators.senha,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  AppPageRoute.modal((_) => const RecuperarSenhaPage()),
                ),
                child: const Text('Esqueci minha senha'),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Entrar',
              icon: Icons.arrow_forward_rounded,
              onPressed: onEntrar,
              loading: carregando,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'ou',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                AppPageRoute.modal((_) => const CriarContaPage()),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: const Text('Criar uma conta'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Logo que pulsa de leve em loop, sem moldura.
class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.scale(
          scale: 1 + 0.04 * t,
          child: child,
        );
      },
      child: Image.asset(
        AppAssets.logoBranca,
        width: 160,
        height: 160,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.pets_rounded, size: 90, color: AppColors.white),
      ),
    );
  }
}
