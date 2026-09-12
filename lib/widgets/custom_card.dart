import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'pressable.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Marca o cartão como escolhido dentro de um grupo de opções: borda e
  /// fundo ganham o tom da marca, sem precisar de um selo à parte.
  final bool selected;

  /// Desliga o `BackdropFilter` (fica só com o preenchimento translúcido,
  /// sem desfoque de verdade). Use `false` em cartões repetidos numa lista
  /// longa — muitos `BackdropFilter` empilhados custam caro numa rolagem.
  final bool blur;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.selected = false,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = GlassSurface(
      padding: padding,
      selected: selected,
      blur: blur,
      // Material transparente: dá suporte a filhos que precisam de um
      // ancestral Material (ListTile, InkWell) sem alterar o visual.
      child: Material(type: MaterialType.transparency, child: child),
    );

    if (onTap == null) return card;

    // Cards tocáveis reagem como célula de lista do iOS: encolhem de leve e
    // devolvem um toque háptico, em vez do respingo de tinta do Material.
    return Pressable(onTap: onTap, child: card);
  }
}
