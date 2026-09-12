import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// O painel de vidro fosco — a superfície padrão de cartões, diálogos e
/// folhas do app ("Liquid Glass"): desfoque do que está atrás, preenchimento
/// branco translúcido (mais claro no topo, simulando luz pegando o rim do
/// vidro) e sombra suave por baixo.
///
/// [blur] liga o `BackdropFilter` de verdade — caro para repetir em listas
/// longas, então cartões de linha (ver `CustomCard.blur`) usam `false` e
/// ficam só com o preenchimento translúcido, que sobre o `GlassBackground`
/// ambiente já lê como vidro sem o custo do filtro.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool selected;
  final bool blur;
  final double blurSigma;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(26)),
    this.padding = EdgeInsets.zero,
    this.selected = false,
    this.blur = true,
    this.blurSigma = 20,
  });

  @override
  Widget build(BuildContext context) {
    final decorated = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: selected
              ? [AppColors.primary.withValues(alpha: 0.24), AppColors.primary.withValues(alpha: 0.12)]
              : [Colors.white.withValues(alpha: 0.66), Colors.white.withValues(alpha: 0.40)],
        ),
        border: Border.all(
          color: selected ? AppColors.primary.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.75),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      padding: padding,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.textPrimary),
        child: child,
      ),
    );

    if (!blur) {
      return ClipRRect(borderRadius: borderRadius, child: decorated);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: decorated,
      ),
    );
  }
}
