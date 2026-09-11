import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/haptics.dart';
import '../utils/motion.dart';

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
    if (value && !_pressed) Haptics.light();
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final outlined = widget.outlined;
    final onColor = outlined ? AppColors.primary : AppColors.white;
    final disabledColor = AppColors.textTertiary;

    final content = widget.loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: onColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 19),
                const SizedBox(width: 9),
              ],
              Text(widget.label),
            ],
          );

    final gradientEnd = Color.lerp(AppColors.primary, Colors.black, 0.16)!;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.965 : 1.0,
        duration: AppMotion.quick,
        curve: AppCurves.spring,
        child: AnimatedContainer(
          duration: AppMotion.quick,
          curve: Curves.easeOut,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: outlined || !_enabled
                ? null
                : LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.primary, gradientEnd],
                  ),
            color: outlined
                ? Colors.transparent
                : (_enabled ? null : AppColors.border),
            borderRadius: BorderRadius.circular(14),
            border: outlined
                ? Border.all(color: _enabled ? AppColors.primary : AppColors.border, width: 1.3)
                : null,
            boxShadow: outlined || !_enabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _pressed ? 0.15 : 0.32),
                      blurRadius: _pressed ? 8 : 18,
                      offset: Offset(0, _pressed ? 2 : 8),
                    ),
                  ],
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _enabled ? onColor : disabledColor,
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: _enabled ? onColor : disabledColor),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
