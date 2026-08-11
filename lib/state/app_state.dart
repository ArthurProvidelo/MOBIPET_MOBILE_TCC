import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService;

  AppState({AuthService? authService}) : _authService = authService ?? AuthService();

  Usuario? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.login(email, senha);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrar({required String nome, required String email, required String senha}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.cadastrar(nome: nome, email: email, senha: senha);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recuperarSenha(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.recuperarSenha(email);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> alterarSenha({required String senhaAtual, required String novaSenha}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.alterarSenha(senhaAtual: senhaAtual, novaSenha: novaSenha);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizarPerfil({String? nome, String? email, String? telefone}) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.atualizarPerfil(
        _currentUser!.copyWith(nome: nome, email: email, telefone: telefone),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
