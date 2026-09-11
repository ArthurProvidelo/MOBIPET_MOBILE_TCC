import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/app_page_route.dart';
import '../../services/viacep_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/primary_button.dart';
import '../main_navigation_page.dart';

class CriarContaPage extends StatefulWidget {
  const CriarContaPage({super.key});

  @override
  State<CriarContaPage> createState() => _CriarContaPageState();
}

class _CriarContaPageState extends State<CriarContaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _viaCepService = ViaCepService();
  bool _buscandoCep = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
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

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    final sucesso = await appState.criarConta(
      nome: _nomeController.text,
      cpf: _cpfController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      senha: _senhaController.text,
      cep: _cepController.text,
      endereco: _enderecoController.text,
    );
    if (!mounted) return;
    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute.fade((_) => const MainNavigationPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.erro ?? 'Erro ao criar conta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<AppState>().carregando;
    const base = 120;
    var step = 0;
    Duration next() => Duration(milliseconds: base + (step++ * 55));

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              FadeSlideIn(
                offsetY: 12,
                child: _Header(onBack: () => Navigator.of(context).pop()),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 90),
                  offsetY: 40,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(34)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
                      child: Form(
                        key: _formKey,
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
                            const SizedBox(height: 22),
                            FadeSlideIn(
                              delay: next(),
                              child: Text(
                                'Seus dados',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FadeSlideIn(
                              delay: next(),
                              child: Text(
                                'Leva menos de um minuto.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 22),
                            FadeSlideIn(
                              delay: next(),
                              child: AppTextField(
                                label: 'Nome completo',
                                controller: _nomeController,
                                prefixIcon: Icons.person_outline_rounded,
                                validator: Validators.nome,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeSlideIn(
                              delay: next(),
                              child: AppTextField(
                                label: 'CPF',
                                controller: _cpfController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [CpfInputFormatter()],
                                prefixIcon: Icons.badge_outlined,
                                validator: Validators.cpf,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeSlideIn(
                              delay: next(),
                              child: AppTextField(
                                label: 'E-mail',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.mail_outline_rounded,
                                validator: Validators.email,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeSlideIn(
                              delay: next(),
                              child: AppTextField(
                                label: 'Telefone',
                                controller: _telefoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [TelefoneInputFormatter()],
                                prefixIcon: Icons.phone_outlined,
                                validator: Validators.telefone,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeSlideIn(
                              delay: next(),
                              child: AppTextField(
                                label: 'CEP',
                                controller: _cepController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [CepInputFormatter()],
                                prefixIcon: Icons.location_on_outlined,
                                validator: (v) => Validators.obrigatorio(
                                    v, 'Informe o CEP'),
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
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.search_rounded),
                                        onPressed: _buscarCep,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeSlideIn(
                              delay: next(),
                              child: AppTextField(
                                label: 'Endereço',
                                controller: _enderecoController,
                                prefixIcon: Icons.home_outlined,
                                validator: (v) => Validators.obrigatorio(
                                    v, 'Informe o endereço'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeSlideIn(
                              delay: next(),
                              child: AppTextField(
                                label: 'Senha',
                                controller: _senhaController,
                                obscureText: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                validator: Validators.senha,
                                helperText:
                                    'Use ao menos 6 caracteres, combinando letras maiúsculas, minúsculas, números e símbolos.',
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeSlideIn(
                              delay: next(),
                              child: AppTextField(
                                label: 'Confirmar senha',
                                controller: _confirmarSenhaController,
                                obscureText: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                validator: (v) => Validators.confirmarSenha(
                                    v, _senhaController.text),
                                textInputAction: TextInputAction.done,
                                onSubmitted: _criarConta,
                              ),
                            ),
                            const SizedBox(height: 28),
                            FadeSlideIn(
                              delay: next(),
                              child: PrimaryButton(
                                label: 'Criar conta',
                                icon: Icons.check_rounded,
                                onPressed: _criarConta,
                                loading: carregando,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Já tenho conta'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: AppColors.white.withValues(alpha: 0.18),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Criar conta',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.white),
                ),
                Text(
                  'Bem-vindo ao MobiPet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset(
            AppAssets.logoBranca,
            width: 46,
            height: 46,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.pets_rounded,
              size: 34,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
