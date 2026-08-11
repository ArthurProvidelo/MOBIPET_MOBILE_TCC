import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/splash_page.dart';
import 'state/agendamentos_provider.dart';
import 'state/app_state.dart';
import 'state/atendimento_provider.dart';
import 'state/pets_provider.dart';
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
      ],
      child: MaterialApp(
        title: 'Mobipet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashPage(),
      ),
    );
  }
}
