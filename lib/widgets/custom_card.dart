import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'pressable.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Marca o cartão como escolhido dentro de um grupo de opções: borda e
  /// fundo ganham o tom da marca, sem precisar de um selo à parte.
  final bool selected;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        // O hairline garante que a borda do cartão continue legível no
        // escuro, onde uma sombra sozinha quase não aparece contra o fundo
        // já bem escuro.
        border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.6 : 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // Material transparente: dá suporte a filhos que precisam de um
      // ancestral Material (ListTile, InkWell) sem alterar o visual.
      child: Material(
        type: MaterialType.transparency,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap == null) return card;

    // Cards tocáveis reagem como célula de lista do iOS: encolhem de leve e
    // devolvem um toque háptico, em vez do respingo de tinta do Material.
    return Pressable(onTap: onTap, child: card);
  }
}
