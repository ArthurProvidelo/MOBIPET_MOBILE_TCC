import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Botão principal do app.
///
/// Versão preenchida: gradiente da marca, brilho suave e animação de "afundar"
/// ao pressionar. Versão [outlined]: contorno sólido, mesma resposta ao toque.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool outlined;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.outlined = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _setPressed(bool value) {
    if (!_enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final outlined = widget.outlined;

    final content = widget.loading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: outlined ? AppColors.primary : AppColors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: 10),
              ],
              Text(widget.label),
            ],
          );

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: outlined
                ? null
                : LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: _enabled
                        ? const [AppColors.primary, Color(0xFF3E77B5)]
                        : const [Color(0xFFB6C4D6), Color(0xFFB6C4D6)],
                  ),
            color: outlined ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(16),
            border: outlined
                ? Border.all(color: AppColors.primary, width: 1.4)
                : null,
            boxShadow: outlined || !_enabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: _pressed ? 0.15 : 0.35,
                      ),
                      blurRadius: _pressed ? 8 : 18,
                      offset: Offset(0, _pressed ? 2 : 8),
                    ),
                  ],
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: outlined ? AppColors.primary : AppColors.white,
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                color: outlined ? AppColors.primary : AppColors.white,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
