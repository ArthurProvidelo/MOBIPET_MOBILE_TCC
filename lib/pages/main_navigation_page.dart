import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/app_page_route.dart';
import '../state/agendamentos_provider.dart';
import '../state/atendimento_provider.dart';
import '../state/pets_provider.dart';
import '../state/servicos_provider.dart';
import '../theme/app_colors.dart';
import '../theme/iconly_icons.dart';
import '../utils/haptics.dart';
import '../utils/motion.dart';
import '../widgets/blur_surface.dart';
import '../widgets/pressable.dart';
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

  void _selecionarAba(int index) {
    if (index == _currentIndex) return;
    Haptics.selection();
    setState(() => _currentIndex = index);
  }

  void _abrirAcoesRapidas() {
    Haptics.medium();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
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
      // As páginas são reconstruídas a cada build (não guardadas numa lista
      // `const` reaproveitada): widgets idênticos entre builds fazem o
      // Flutter pular a reconstrução deles, então uma troca de tema global
      // (que não passa por Theme.of, e sim pelas cores estáticas de
      // AppColors) nunca chegava até quem já estava "escondido" atrás do
      // IndexedStack — o cartão de próximos agendamentos, por exemplo,
      // ficava com as cores do tema anterior até a lista mudar por outro
      // motivo. Widgets novos a cada build resolvem isso sem custo real,
      // já que o IndexedStack preserva o estado de cada aba de qualquer forma.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(),
          PetsPage(),
          AgendamentosPage(),
          PerfilPage(),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: _selecionarAba,
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.4),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          // "Material" translúcido com desfoque — a tab bar deixa a página
          // por trás borrada e visível em vez de escondida, como no iOS.
          child: BlurSurface(
            borderRadius: BorderRadius.circular(35),
            color: AppColors.surface.withValues(alpha: 0.72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Geometria dos 4 espaços de aba (o botão central tem
                  // largura fixa e "quebra" a distribuição uniforme).
                  const centerWidth = 70.0;
                  const pillSize = 52.0;
                  final slotWidth = (constraints.maxWidth - centerWidth) / 4;

                  double centerXFor(int slot) {
                    if (slot < 2) return slot * slotWidth + slotWidth / 2;
                    final depoisDoCentro = slot - 2;
                    return 2 * slotWidth + centerWidth + depoisDoCentro * slotWidth + slotWidth / 2;
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // O "vidro líquido": uma cápsula translúcida que
                      // desliza e assenta com uma leve mola atrás da aba
                      // ativa — o mesmo princípio da tab bar do iOS 26.
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 460),
                        curve: AppCurves.spring,
                        left: centerXFor(currentIndex) - pillSize / 2,
                        top: (constraints.maxHeight - pillSize) / 2,
                        child: const _LiquidPill(size: pillSize),
                      ),
                      Row(
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
                    ],
                  );
                },
              ),
            ),
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
    // O realce de "selecionado" agora é a cápsula de vidro que desliza por
    // trás (ver _LiquidPill) — aqui só resta o ícone e o pequeno salto dele.
    return Expanded(
      child: Pressable(
        onTap: onTap,
        haptic: false, // o toque háptico de troca de aba é disparado no pai
        child: SizedBox(
          height: double.infinity,
          child: Center(
            child: AnimatedScale(
              // Pequeno "salto" ao ativar a aba (overshoot do easeOutBack).
              scale: selected ? 1.0 : 0.9,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: Icon(
                selected ? item.bold : item.light,
                size: 24,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                semanticLabel: item.label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A cápsula de vidro translúcida que marca a aba ativa na tab bar,
/// deslizando entre as posições com uma leve mola — o efeito "Liquid
/// Glass" das tab bars do iOS 26.
class _LiquidPill extends StatelessWidget {
  final double size;

  const _LiquidPill({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white.withValues(alpha: 0.14),
            Colors.transparent,
          ],
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
      child: Pressable(
        onTap: onTap,
        haptic: false, // quem chama já dispara Haptics.medium
        pressedScale: 0.92,
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
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
          child: const Icon(IconlyBold.plus, color: AppColors.white, size: 26),
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
