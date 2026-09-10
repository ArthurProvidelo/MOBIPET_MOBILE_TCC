import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/app_page_route.dart';
import '../state/agendamentos_provider.dart';
import '../state/atendimento_provider.dart';
import '../state/pets_provider.dart';
import '../state/servicos_provider.dart';
import '../theme/app_colors.dart';
import '../theme/iconly_icons.dart';
import 'agendamentos/agendamentos_page.dart';
import 'agendamentos/novo_agendamento_page.dart';
import 'home/home_page.dart';
import 'perfil/perfil_page.dart';
import 'pets/pet_form_page.dart';
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

  void _abrirAcoesRapidas() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Criar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              ListTile(
                leading: const _RoundIcon(icon: IconlyBold.calendar),
                title: const Text('Novo agendamento'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    AppPageRoute.modal((_) => const NovoAgendamentoPage()),
                  );
                },
              ),
              ListTile(
                leading: const _RoundIcon(icon: Icons.pets),
                title: const Text('Cadastrar pet'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    AppPageRoute.modal((_) => const PetFormPage()),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onCenterTap: _abrirAcoesRapidas,
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  static const _items = <_NavItem>[
    _NavItem(light: IconlyLight.home, bold: IconlyBold.home, label: 'Home'),
    // Iconly não tem "pata": usamos o ícone de pet do Material aqui.
    _NavItem(light: Icons.pets, bold: Icons.pets, label: 'Meus Pets'),
    _NavItem(light: IconlyLight.calendar, bold: IconlyBold.calendar, label: 'Agendamentos'),
    _NavItem(light: IconlyLight.profile, bold: IconlyBold.profile, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.4),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavButton(
                item: _items[0],
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavButton(
                item: _items[1],
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _CenterButton(onTap: onCenterTap),
              _NavButton(
                item: _items[2],
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavButton(
                item: _items[3],
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: selected ? 16 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              selected ? item.bold : item.light,
              size: 24,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              semanticLabel: item.label,
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: const Icon(IconlyBold.plus, color: AppColors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;

  const _RoundIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _NavItem {
  final IconData light;
  final IconData bold;
  final String label;

  const _NavItem({required this.light, required this.bold, required this.label});
}
