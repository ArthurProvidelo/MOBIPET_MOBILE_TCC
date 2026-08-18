import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../state/agendamentos_provider.dart';
import '../state/atendimento_provider.dart';
import '../state/pets_provider.dart';
import '../state/servicos_provider.dart';
import '../theme/app_colors.dart';
import 'agendamentos/agendamentos_page.dart';
import 'home/home_page.dart';
import 'perfil/perfil_page.dart';
import 'pets/pets_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    PetsPage(),
    AgendamentosPage(),
    PerfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetsProvider>().carregar();
      context.read<AgendamentosProvider>().carregar();
      context.read<AtendimentoProvider>().carregar();
      context.read<ServicosProvider>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home_rounded),
                title: const Text('Home'),
                selectedColor: AppColors.primary,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.pets_rounded),
                title: const Text('Meus Pets'),
                selectedColor: AppColors.primary,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.calendar_today_rounded),
                title: const Text('Agendamentos'),
                selectedColor: AppColors.primary,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.person_rounded),
                title: const Text('Perfil'),
                selectedColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
