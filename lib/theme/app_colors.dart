import 'package:flutter/material.dart';

/// Um conjunto completo de cores semânticas — um "tema" claro ou escuro.
/// Uso interno de [AppColors]; não precisa ser referenciado fora daqui.
class AppPalette {
  final Color primary;
  final Color primaryLight;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color success;
  final Color danger;
  final Color warning;
  final Color border;
  final Color shadow;

  const AppPalette({
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.danger,
    required this.warning,
    required this.border,
    required this.shadow,
  });
}

/// Paleta oficial da identidade visual MobiPet — clara e escura.
///
/// Os tokens são expostos como getters (`AppColors.primary`, não uma
/// constante) porque o valor muda com [setBrightness]: [MobipetApp] observa
/// o brilho da plataforma e chama isso a cada mudança, então qualquer widget
/// que leia `AppColors.x` num `build()` pega sempre a cor do tema atual.
/// [AppTheme] usa [light]/[dark] diretamente para montar os dois `ThemeData`
/// (que precisam existir ao mesmo tempo, independente do brilho corrente).
abstract class AppColors {
  static const AppPalette light = AppPalette(
    primary: Color(0xFF2D5D96),
    primaryLight: Color(0xFF58B8E8),
    accent: Color(0xFFF59A23),
    background: Color(0xFFF3F5F9),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF7F9FC),
    textPrimary: Color(0xFF1F2A37),
    textSecondary: Color(0xFF6B7280),
    textTertiary: Color(0xFF9AA4B2),
    success: Color(0xFF22C55E),
    danger: Color(0xFFFF3B30),
    warning: Color(0xFFF59A23),
    border: Color(0xFFE3E7EE),
    shadow: Color(0x14243B53),
  );

  static const AppPalette dark = AppPalette(
    primary: Color(0xFF5AA9E6),
    primaryLight: Color(0xFF7CC3F2),
    accent: Color(0xFFFFB454),
    background: Color(0xFF0B0E13),
    surface: Color(0xFF17191F),
    surfaceSecondary: Color(0xFF1F2229),
    textPrimary: Color(0xFFF2F4F7),
    textSecondary: Color(0xFFA7B0BD),
    textTertiary: Color(0xFF6B7280),
    success: Color(0xFF32D74B),
    danger: Color(0xFFFF453A),
    warning: Color(0xFFFFB454),
    border: Color(0xFF262A32),
    shadow: Color(0x66000000),
  );

  static Brightness _brightness = Brightness.light;
  static bool get _isDark => _brightness == Brightness.dark;
  static AppPalette get _p => _isDark ? dark : light;

  /// Chamado pelo observador de brilho da plataforma em [MobipetApp]. Não
  /// chame diretamente fora dali.
  static void setBrightness(Brightness value) => _brightness = value;

  static Color get primary => _p.primary;
  static Color get primaryLight => _p.primaryLight;
  static Color get accent => _p.accent;
  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get surfaceSecondary => _p.surfaceSecondary;
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textTertiary => _p.textTertiary;
  static Color get success => _p.success;
  static Color get danger => _p.danger;
  static Color get warning => _p.warning;
  static Color get border => _p.border;
  static Color get shadow => _p.shadow;

  /// Texto/ícone sobre uma superfície colorida (botão preenchido, badge do
  /// centro da tab bar, chip de status) — fixo, não varia com o tema, porque
  /// o contraste é contra a cor de destaque, não contra a página.
  static const Color white = Color(0xFFFFFFFF);

  /// "Chip" de contraste do SnackBar: sempre o oposto do tema atual, para
  /// continuar legível tanto no claro quanto no escuro (convenção Material).
  static Color get inverseSurface => _isDark ? light.textPrimary : dark.background;
  static Color get onInverseSurface => _isDark ? light.surface : dark.textPrimary;
}
