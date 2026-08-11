import '../models/usuario.dart';
import 'mock_data.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

/// Camada mockada de autenticação. Métodos e assinaturas foram desenhados
/// para que, no futuro, o corpo de cada um seja trocado por uma chamada
/// HTTP a uma API Laravel sem alterar quem os consome.
class AuthService {
  static const _delay = Duration(milliseconds: 700);

  Usuario? _sessao;

  Future<Usuario> login(String email, String senha) async {
    await Future.delayed(_delay);
    if (email.trim().toLowerCase() != MockData.usuario.email.toLowerCase() || senha.isEmpty) {
      throw AuthException('E-mail ou senha inválidos');
    }
    _sessao = MockData.usuario;
    return _sessao!;
  }

  Future<Usuario> cadastrar({required String nome, required String email, required String senha}) async {
    await Future.delayed(_delay);
    final novo = Usuario(id: 'u_novo', nome: nome, email: email);
    _sessao = novo;
    return novo;
  }

  Future<void> recuperarSenha(String email) async {
    await Future.delayed(_delay);
  }

  Future<void> alterarSenha({required String senhaAtual, required String novaSenha}) async {
    await Future.delayed(_delay);
  }

  Future<Usuario> atualizarPerfil(Usuario usuario) async {
    await Future.delayed(_delay);
    _sessao = usuario;
    return usuario;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sessao = null;
  }
}
