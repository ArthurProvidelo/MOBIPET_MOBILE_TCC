import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persiste a preferência de aparência escolhida pelo usuário (claro/escuro/
/// automático), para o app abrir sempre no modo que ele deixou da última vez.
abstract class ThemeStorage {
  static const _storage = FlutterSecureStorage();
  static const _chave = 'mobipet_theme_mode';

  static Future<void> salvar(String modo) => _storage.write(key: _chave, value: modo);

  static Future<String?> ler() => _storage.read(key: _chave);
}
