import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botão principal grande, com estado de carregamento embutido.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = FilledButton(
      onPressed: loading ? null : onPressed,
      style: color == null
          ? null
          : FilledButton.styleFrom(backgroundColor: color),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: loading
            ? const SizedBox(
                key: ValueKey<String>('loading'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.white,
                ),
              )
            : Row(
                key: const ValueKey<String>('label'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(label, maxLines: 1),
                    ),
                  ),
                ],
              ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
