import 'package:flutter/services.dart';

/// Aplica os caracteres fixos de [mask] (tudo que não é `#`) sobre os dígitos
/// de [valor], até o limite de `#`s. Usado tanto ao digitar quanto para
/// exibir valores já salvos.
String aplicarMascara(String valor, String mask) {
  final digits = valor.replaceAll(RegExp(r'\D'), '');
  final buffer = StringBuffer();
  var i = 0;
  for (final maskChar in mask.split('')) {
    if (i >= digits.length) break;
    if (maskChar == '#') {
      buffer.write(digits[i]);
      i++;
    } else {
      buffer.write(maskChar);
    }
  }
  return buffer.toString();
}

class _MaskTextInputFormatter extends TextInputFormatter {
  final String mask;

  _MaskTextInputFormatter({required this.mask});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = aplicarMascara(newValue.text, mask);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class CpfInputFormatter extends _MaskTextInputFormatter {
  CpfInputFormatter() : super(mask: '###.###.###-##');
}

class TelefoneInputFormatter extends _MaskTextInputFormatter {
  TelefoneInputFormatter() : super(mask: '(##) #####-####');
}

class CepInputFormatter extends _MaskTextInputFormatter {
  CepInputFormatter() : super(mask: '#####-###');
}

/// Máscaras prontas para exibir valores já armazenados.
abstract class Mascaras {
  static String cpf(String v) => aplicarMascara(v, '###.###.###-##');
  static String telefone(String v) => aplicarMascara(v, '(##) #####-####');
  static String cep(String v) => aplicarMascara(v, '#####-###');
}
