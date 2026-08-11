abstract class Validators {
  static String? obrigatorio(String? value, {String campo = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$campo é obrigatório';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe seu e-mail';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Informe um e-mail válido';
    return null;
  }

  static String? senha(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Informe sua senha';
    if (value.length < minLength) return 'A senha deve ter ao menos $minLength caracteres';
    return null;
  }

  static String? Function(String?) confirmacao(String? Function() original, {String mensagem = 'As senhas não coincidem'}) {
    return (value) {
      if (value != original()) return mensagem;
      return null;
    };
  }

  static String? numero(String? value, {String campo = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$campo é obrigatório';
    final normalized = value.replaceAll(',', '.');
    if (double.tryParse(normalized) == null) return '$campo deve ser um número válido';
    return null;
  }
}
