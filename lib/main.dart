import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'services/appointment_repository.dart';
import 'services/auth_service.dart';
import 'services/monitoring_service.dart';
import 'services/pet_repository.dart';
import 'theme/app_theme.dart';
import 'utils/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  runApp(const MobipetApp());
}

class MobipetApp extends StatelessWidget {
  const MobipetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <ChangeNotifierProvider<ChangeNotifier>>[
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<PetRepository>(create: (_) => PetRepository()),
        ChangeNotifierProvider<AppointmentRepository>(
          create: (_) => AppointmentRepository(),
        ),
        ChangeNotifierProvider<MonitoringService>(
          create: (_) => MonitoringService(),
        ),
      ],
      child: MaterialApp(
        title: 'MOBIPET Monitoramento',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const <Locale>[Locale('pt', 'BR')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
