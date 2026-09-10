import '../models/usuario.dart';
import 'api_client.dart';
import 'token_storage.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<Usuario> login({required String email, required String senha}) async {
    final resposta = await _client.post('/login', {'email': email, 'senha': senha});
    await TokenStorage.salvar(resposta['token'] as String);
    return Usuario.fromJson(resposta['cliente'] as Map<String, dynamic>);
  }

  Future<Usuario> criarConta({
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
    required String senha,
    required String cep,
    required String endereco,
  }) async {
    final resposta = await _client.post('/register', {
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'telefone': telefone,
      'senha': senha,
      'cep': cep,
      'endereco': endereco,
    });
    await TokenStorage.salvar(resposta['token'] as String);
    return Usuario.fromJson(resposta['cliente'] as Map<String, dynamic>);
  }

  /// Retorna o cliente da sessão salva, ou null se não houver token ou ele
  /// não for mais válido (ex: expirado/revogado no servidor).
  Future<Usuario?> usuarioAtual() async {
    final token = await TokenStorage.ler();
    if (token == null) return null;
    try {
      final resposta = await _client.get('/me');
      return Usuario.fromJson(resposta['cliente'] as Map<String, dynamic>);
    } catch (_) {
      await TokenStorage.limpar();
      return null;
    }
  }

  Future<Usuario> atualizarPerfil({
    required String nome,
    required String email,
    required String telefone,
    required String cep,
    required String endereco,
  }) async {
    final resposta = await _client.put('/perfil', {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cep': cep,
      'endereco': endereco,
    });
    return Usuario.fromJson(resposta['cliente'] as Map<String, dynamic>);
  }

  Future<void> alterarSenha({required String senhaAtual, required String novaSenha}) {
    return _client.put('/senha', {'senha_atual': senhaAtual, 'nova_senha': novaSenha});
  }

  Future<void> recuperarSenha({required String email}) {
    return _client.post('/esqueci-senha', {'email': email});
  }

  Future<void> logout() async {
    try {
      await _client.post('/logout');
    } catch (_) {
      // Mesmo que a chamada falhe (ex: token já expirado), limpa localmente.
    }
    await TokenStorage.limpar();
  }
}
