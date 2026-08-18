abstract class Validators {
  static String? nome(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o nome';
    if (value.trim().length < 2) return 'Nome muito curto';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o e-mail';
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'E-mail inválido';
    return null;
  }

  static String? senha(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha';
    if (value.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  static String? confirmarSenha(String? value, String senhaOriginal) {
    if (value == null || value.isEmpty) return 'Confirme a senha';
    if (value != senhaOriginal) return 'As senhas não coincidem';
    return null;
  }

  static String? telefone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o telefone';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Telefone inválido';
    return null;
  }

  static String? obrigatorio(String? value, [String mensagem = 'Campo obrigatório']) {
    if (value == null || value.trim().isEmpty) return mensagem;
    return null;
  }

  static String? peso(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o peso';
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return 'Peso inválido';
    return null;
  }

  static String? cpf(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o CPF';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return 'CPF inválido';
    return null;
  }
}
