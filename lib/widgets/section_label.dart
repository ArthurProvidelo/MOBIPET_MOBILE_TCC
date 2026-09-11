import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Rótulo de seção em caixa alta, cinza e pequeno — o mesmo estilo das
/// listas agrupadas do iOS (Ajustes, Contatos), usado para separar blocos
/// dentro de um formulário sem pesar visualmente.
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionLabel(this.text, {super.key, this.padding = const EdgeInsets.fromLTRB(4, 0, 4, 8)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
