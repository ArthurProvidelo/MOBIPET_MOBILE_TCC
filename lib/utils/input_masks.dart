import 'package:flutter/services.dart';

/// Máscaras simples de entrada (telefone, CPF, peso).
class InputMasks {
  const InputMasks._();

  static List<TextInputFormatter> get phone => <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(11),
    _PatternFormatter(_formatPhone),
  ];

  static List<TextInputFormatter> get document => <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(11),
    _PatternFormatter(_formatDocument),
  ];

  static List<TextInputFormatter> get decimal => <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
    LengthLimitingTextInputFormatter(6),
  ];

  static String _formatPhone(String digits) {
    if (digits.isEmpty) return '';
    final StringBuffer buffer = StringBuffer('(');
    buffer.write(digits.substring(0, digits.length.clamp(0, 2)));
    if (digits.length >= 2) buffer.write(') ');
    if (digits.length > 2) {
      final int splitAt = digits.length > 10 ? 7 : 6;
      buffer.write(digits.substring(2, digits.length.clamp(2, splitAt)));
      if (digits.length > splitAt) {
        buffer.write('-');
        buffer.write(digits.substring(splitAt));
      }
    }
    return buffer.toString();
  }

  static String _formatDocument(String digits) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class _PatternFormatter extends TextInputFormatter {
  const _PatternFormatter(this.format);

  final String Function(String digits) format;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final String formatted = format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
