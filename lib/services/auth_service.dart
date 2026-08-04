import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'mock_data.dart';

/// Erro de negócio das operações de autenticação.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Autenticação mockada.
///
/// Substituir as chamadas de [Future.delayed] por requisições à API Laravel
/// (`POST /api/login`, `POST /api/register`, `POST /api/password/forgot`)
/// mantendo a mesma assinatura pública.
class AuthService extends ChangeNotifier {
  AppUser? _currentUser;

  /// E-mails e senhas aceitos pelo protótipo.
  final Map<String, String> _credentials = <String, String>{
    MockData.demoEmail: MockData.demoPassword,
  };

  AppUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  static const Duration _latency = Duration(milliseconds: 900);

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    final String key = email.trim().toLowerCase();
    if (!_credentials.containsKey(key)) {
      throw const AuthException(
        'E-mail não encontrado. Verifique e tente novamente.',
      );
    }
    if (_credentials[key] != password) {
      throw const AuthException('Senha incorreta. Tente novamente.');
    }
    _currentUser = key == MockData.demoEmail
        ? MockData.user()
        : MockData.user().copyWith(email: key);
    notifyListeners();
    return _currentUser!;
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    final String key = email.trim().toLowerCase();
    if (_credentials.containsKey(key)) {
      throw const AuthException('Já existe uma conta com este e-mail.');
    }
    _credentials[key] = password;
    _currentUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: key,
      phone: phone,
      document: '',
      address: '',
      memberSince: DateTime.now(),
    );
    notifyListeners();
    return _currentUser!;
  }

  Future<void> sendPasswordRecovery(String email) async {
    await Future<void>.delayed(_latency);
    if (email.trim().isEmpty) {
      throw const AuthException('Informe um e-mail válido.');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String document,
    required String address,
  }) async {
    await Future<void>.delayed(_latency);
    final AppUser? user = _currentUser;
    if (user == null) throw const AuthException('Sessão expirada.');
    _currentUser = user.copyWith(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone,
      document: document,
      address: address,
    );
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(_latency);
    final AppUser? user = _currentUser;
    if (user == null) throw const AuthException('Sessão expirada.');
    if (_credentials[user.email] != currentPassword) {
      throw const AuthException('A senha atual está incorreta.');
    }
    _credentials[user.email] = newPassword;
    notifyListeners();
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    notifyListeners();
  }
}
