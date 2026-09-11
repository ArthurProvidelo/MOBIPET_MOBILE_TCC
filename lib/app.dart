import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/splash_page.dart';
import 'state/agendamentos_provider.dart';
import 'state/app_state.dart';
import 'state/atendimento_provider.dart';
import 'state/funcionarios_provider.dart';
import 'state/pets_provider.dart';
import 'state/servicos_provider.dart';
import 'state/theme_controller.dart';
import 'theme/app_colors.dart';
import 'theme/app_scroll_behavior.dart';
import 'theme/app_theme.dart';

class MobipetApp extends StatelessWidget {
  const MobipetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => PetsProvider()),
        ChangeNotifierProvider(create: (_) => AgendamentosProvider()),
        ChangeNotifierProvider(create: (_) => AtendimentoProvider()),
        ChangeNotifierProvider(create: (_) => ServicosProvider()),
        ChangeNotifierProvider(create: (_) => FuncionariosProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()..carregar()),
      ],
      child: const _BrightnessScope(),
    );
  }
}

/// Mantém [AppColors] sincronizada com a aparência efetiva do app.
///
/// A aparência efetiva é: a preferência manual do usuário
/// ([ThemeController]) quando ela não é "automático", ou o brilho do
/// sistema operacional caso contrário. `MaterialApp(theme:, darkTheme:,
/// themeMode:)` já troca sozinho o `ThemeData` (e por tabela tudo que lê
/// `Theme.of(context)`) nessa mesma lógica — só que várias cores do app são
/// lidas direto de `AppColors.x` (sem passar por Theme, para não precisar
/// carregar `context` em toda parte); este widget garante que esse valor
/// também acompanha a troca, reconstruindo a árvore no mesmo instante em
/// que o `MaterialApp` troca de tema.
class _BrightnessScope extends StatefulWidget {
  const _BrightnessScope();

  @override
  State<_BrightnessScope> createState() => _BrightnessScopeState();
}

class _BrightnessScopeState extends State<_BrightnessScope> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final aparencia = context.watch<ThemeController>().aparencia;
    final Brightness efetivo;
    switch (aparencia) {
      case AppAppearance.light:
        efetivo = Brightness.light;
        break;
      case AppAppearance.dark:
        efetivo = Brightness.dark;
        break;
      case AppAppearance.system:
        efetivo = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        break;
    }
    AppColors.setBrightness(efetivo);

    return MaterialApp(
      title: 'MobiPet Monitoramento',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: aparencia.themeMode,
      scrollBehavior: const AppScrollBehavior(),
      home: const SplashPage(),
    );
  }
}
