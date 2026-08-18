import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persiste o token de autenticação (Sanctum) do cliente logado.
abstract class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _chave = 'mobipet_token';

  static Future<void> salvar(String token) => _storage.write(key: _chave, value: token);

  static Future<String?> ler() => _storage.read(key: _chave);

  static Future<void> limpar() => _storage.delete(key: _chave);
}
