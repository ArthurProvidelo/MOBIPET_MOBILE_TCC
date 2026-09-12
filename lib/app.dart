import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/splash_page.dart';
import 'state/agendamentos_provider.dart';
import 'state/app_state.dart';
import 'state/atendimento_provider.dart';
import 'state/funcionarios_provider.dart';
import 'state/pets_provider.dart';
import 'state/servicos_provider.dart';
import 'theme/app_scroll_behavior.dart';
import 'theme/app_theme.dart';
import 'widgets/glass_background.dart';

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
      ],
      child: MaterialApp(
        title: 'MobiPet Monitoramento',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        scrollBehavior: const AppScrollBehavior(),
        // Fundo de profundidade montado uma única vez para o app inteiro:
        // toda tela é transparente por padrão (ver AppTheme.theme) e deixa
        // isto aparecer atrás — é o que dá ao vidro (GlassSurface/BlurSurface)
        // algo para refratar. Telas com fundo próprio (splash, autenticação)
        // pintam por cima normalmente.
        builder: (context, child) => GlassBackground.ambient(child: child ?? const SizedBox.shrink()),
        home: const SplashPage(),
      ),
    );
  }
}
