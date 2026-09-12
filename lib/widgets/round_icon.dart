import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ícone num círculo colorido — usado como "leading" de opções em folhas de
/// ação (bottom sheets), no lugar do ícone solto e cinza padrão do
/// [ListTile], para dar mais peso visual às ações de destaque.
class RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const RoundIcon({super.key, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final cor = color ?? AppColors.primary;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: cor, size: 20),
    );
  }
}
