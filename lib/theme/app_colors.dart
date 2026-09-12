import 'package:flutter/material.dart';

/// Paleta oficial da identidade visual MobiPet — só modo claro.
///
/// Os tokens são expostos como getters estáticos (`AppColors.primary`) para
/// que o resto do app continue lendo exatamente como antes; hoje são valores
/// fixos, mas mantêm essa forma para não precisar tocar em nenhum outro
/// arquivo caso a paleta mude no futuro.
abstract class AppColors {
  static const Color primary = Color(0xFF2D5D96);
  static const Color primaryLight = Color(0xFF58B8E8);
  static const Color accent = Color(0xFFF59A23);
  static const Color background = Color(0xFFF3F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF7F9FC);
  static const Color textPrimary = Color(0xFF1F2A37);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9AA4B2);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFF59A23);
  static const Color border = Color(0xFFE3E7EE);
  static const Color shadow = Color(0x14243B53);

  /// Texto/ícone sobre uma superfície colorida (botão preenchido, badge do
  /// centro da tab bar, chip de status) — fixo, sempre branco.
  static const Color white = Color(0xFFFFFFFF);

  /// "Chip" de contraste do SnackBar: sempre escuro sobre um fundo claro,
  /// para continuar legível (convenção Material de "inverse surface").
  static const Color inverseSurface = textPrimary;
  static const Color onInverseSurface = surface;
}
