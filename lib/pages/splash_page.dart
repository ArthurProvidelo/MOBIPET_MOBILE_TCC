import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import 'auth/login_page.dart';
import 'main_navigation_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeIn));
    _controller.forward();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final autoLoginFuture = context.read<AppState>().tentarAutoLogin();
    final animacaoFuture = Future.delayed(const Duration(milliseconds: 1900));
    final resultados = await Future.wait([autoLoginFuture, animacaoFuture]);
    if (!mounted) return;

    final autenticado = resultados[0] as bool;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => autenticado ? const MainNavigationPage() : const LoginPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Image.asset(
                    AppAssets.logoColorida,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.pets_rounded, size: 52, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'MOBIPET',
                  style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Monitoramento',
                  style: TextStyle(color: AppColors.white.withValues(alpha: 0.85), fontSize: 15, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
