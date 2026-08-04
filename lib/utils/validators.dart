/// Validações reutilizadas nos formulários.
class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[\w.\-+]+@([\w\-]+\.)+[a-zA-Z]{2,}$',
  );

  static String? required(String? value, {String field = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório.';
    }
    return null;
  }

  static String? name(String? value) {
    final String? empty = required(value, field: 'O nome');
    if (empty != null) return empty;
    if (value!.trim().length < 3) return 'Informe o nome completo.';
    return null;
  }

  static String? email(String? value) {
    final String? empty = required(value, field: 'O e-mail');
    if (empty != null) return empty;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  static String? password(String? value) {
    final String? empty = required(value, field: 'A senha');
    if (empty != null) return empty;
    if (value!.length < 6) return 'A senha deve ter ao menos 6 caracteres.';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final String? empty = required(value, field: 'A confirmação');
    if (empty != null) return empty;
    if (value != password) return 'As senhas não coincidem.';
    return null;
  }

  static String? phone(String? value) {
    final String? empty = required(value, field: 'O telefone');
    if (empty != null) return empty;
    final String digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Informe um telefone válido com DDD.';
    return null;
  }

  static String? weight(String? value) {
    final String? empty = required(value, field: 'O peso');
    if (empty != null) return empty;
    final double? parsed = double.tryParse(value!.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return 'Informe um peso válido.';
    if (parsed > 120) return 'Informe um peso realista (até 120 kg).';
    return null;
  }
}
