import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Usuario? _usuario;
  bool _carregando = false;
  bool _verificandoSessao = true;
  String? erro;

  Usuario? get usuario => _usuario;
  bool get autenticado => _usuario != null;
  bool get carregando => _carregando;

  /// true enquanto a Splash ainda está checando se há uma sessão salva.
  bool get verificandoSessao => _verificandoSessao;

  /// Chamado uma vez, na Splash: tenta restaurar a sessão a partir do token
  /// salvo localmente. Retorna true se havia uma sessão válida.
  Future<bool> tentarAutoLogin() async {
    _usuario = await _authService.usuarioAtual();
    _verificandoSessao = false;
    notifyListeners();
    return autenticado;
  }

  Future<bool> login({required String email, required String senha}) async {
    _setCarregando(true);
    erro = null;
    try {
      _usuario = await _authService.login(email: email, senha: senha);
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> criarConta({
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
    required String senha,
    required String endereco,
  }) async {
    _setCarregando(true);
    erro = null;
    try {
      _usuario = await _authService.criarConta(
        nome: nome,
        cpf: cpf,
        email: email,
        telefone: telefone,
        senha: senha,
        endereco: endereco,
      );
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> recuperarSenha({required String email}) async {
    _setCarregando(true);
    erro = null;
    try {
      await _authService.recuperarSenha(email: email);
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> atualizarPerfil({
    required String nome,
    required String email,
    required String telefone,
    required String endereco,
  }) async {
    _setCarregando(true);
    erro = null;
    try {
      _usuario = await _authService.atualizarPerfil(
        nome: nome,
        email: email,
        telefone: telefone,
        endereco: endereco,
      );
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> alterarSenha({required String senhaAtual, required String novaSenha}) async {
    _setCarregando(true);
    erro = null;
    try {
      await _authService.alterarSenha(senhaAtual: senhaAtual, novaSenha: novaSenha);
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _usuario = null;
    notifyListeners();
  }

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }
}
