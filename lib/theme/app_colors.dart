import 'package:flutter/material.dart';

/// Paleta oficial da marca MOBIPET.
class AppColors {
  const AppColors._();

  static const Color blue = Color(0xFF2D5D96);
  static const Color lightBlue = Color(0xFF58B8E8);
  static const Color orange = Color(0xFFF59A23);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F9FC);
  static const Color text = Color(0xFF243B53);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFE0A106);
  static const Color danger = Color(0xFFD9455F);
  static const Color divider = Color(0xFFE4E9F2);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, lightBlue],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, Color(0xFFF7C04A)],
  );
}
