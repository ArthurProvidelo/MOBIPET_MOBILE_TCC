import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final bool readOnly;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? helperText;

  /// Ação mostrada no teclado. Por padrão "Próximo" — pular para o campo
  /// seguinte do formulário, como no iOS; passe [TextInputAction.done] no
  /// último campo.
  final TextInputAction textInputAction;

  /// Chamado ao confirmar no teclado. Se omitido, o padrão é avançar para o
  /// próximo campo (ou fechar o teclado, se [textInputAction] for "done").
  final VoidCallback? onSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.inputFormatters,
    this.helperText,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;
  bool _focused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _focused ? AppColors.primary : AppColors.textSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        // Só "acende" um halo suave no foco — o hairline de 1px do tema
        // (ver InputDecorationTheme) já resolve o contorno no repouso.
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText && _obscured,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        maxLines: widget.maxLines,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: (_) {
          if (widget.onSubmitted != null) {
            widget.onSubmitted!();
          } else if (widget.textInputAction == TextInputAction.done) {
            _focusNode.unfocus();
          } else {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helperText,
          helperMaxLines: 3,
          prefixIcon: widget.prefixIcon != null
              ? AnimatedScale(
                  scale: _focused ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(widget.prefixIcon, color: accentColor),
                )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: accentColor,
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                )
              : widget.suffixIcon,
        ),
      ),
    );
  }
}
