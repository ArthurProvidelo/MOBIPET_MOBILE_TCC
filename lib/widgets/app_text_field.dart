import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Campo de texto padrão do app, com rótulo externo e ícone.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscure = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.autofillHints,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool obscure;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final Iterable<String>? autofillHints;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          obscureText: _obscured,
          maxLines: _obscured ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          enabled: widget.enabled,
          autofillHints: widget.autofillHints,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 22),
            suffixIcon: widget.obscure
                ? IconButton(
                    tooltip: _obscured ? 'Mostrar senha' : 'Ocultar senha',
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 22,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffix,
          ),
        ),
      ],
    );
  }
}
