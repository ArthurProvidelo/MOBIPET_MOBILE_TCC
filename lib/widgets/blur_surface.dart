import 'dart:ui';

import 'package:flutter/material.dart';

/// Um painel translúcido com desfoque de fundo — a "materialidade" do iOS
/// usada nas tab bars, nav bars e folhas modais, que deixa o conteúdo por
/// baixo borrado e sutilmente visível em vez de escondido atrás de um
/// bloco opaco.
class BlurSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final Color color;
  final double sigma;

  const BlurSurface({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius,
    this.sigma = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(color: color, child: child),
      ),
    );
  }
}
