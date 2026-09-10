import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'pressable.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
