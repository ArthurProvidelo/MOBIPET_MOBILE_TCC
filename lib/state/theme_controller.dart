import 'package:flutter/material.dart';
import '../services/theme_storage.dart';

/// Preferência de aparência do usuário — "Automático" segue o sistema,
/// como a tela de Ajustes do iPhone (Vídeo e Brilho > Aparência).
enum AppAppearance {
  system('sistema', 'Automático', Icons.brightness_auto_rounded),
  light('claro', 'Claro', Icons.light_mode_rounded),
  dark('escuro', 'Escuro', Icons.dark_mode_rounded);

  final String chave;
  final String label;
  final IconData icon;

  const AppAppearance(this.chave, this.label, this.icon);

  static AppAppearance fromChave(String? chave) {
    return AppAppearance.values.firstWhere(
      (a) => a.chave == chave,
      orElse: () => AppAppearance.system,
    );
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppAppearance.system:
        return ThemeMode.system;
      case AppAppearance.light:
        return ThemeMode.light;
      case AppAppearance.dark:
        return ThemeMode.dark;
    }
  }
}

/// Guarda a preferência de aparência do usuário e a mantém sincronizada em
/// disco. [MobipetApp] observa isto para decidir o `ThemeMode` do
/// `MaterialApp` e o brilho efetivo de [AppColors].
class ThemeController extends ChangeNotifier {
  AppAppearance _aparencia = AppAppearance.system;

  AppAppearance get aparencia => _aparencia;

  Future<void> carregar() async {
    final salvo = await ThemeStorage.ler();
    _aparencia = AppAppearance.fromChave(salvo);
    notifyListeners();
  }

  Future<void> definir(AppAppearance aparencia) async {
    if (aparencia == _aparencia) return;
    _aparencia = aparencia;
    notifyListeners();
    await ThemeStorage.salvar(aparencia.chave);
  }
}
