import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Escala tipográfica no espírito do iOS (Large Title → Caption), usando
/// Inter — geometricamente a mais próxima da SF Pro entre as fontes livres
/// do Google Fonts — com o leve tracking negativo que a Apple usa nos
/// tamanhos grandes.
///
/// Os nomes seguem os slots do [TextTheme] do Material para que o resto do
/// app continue lendo `Theme.of(context).textTheme.titleLarge` etc. sem
/// precisar saber que por trás disso tem uma escala iOS.
abstract class AppTypography {
  static TextTheme textTheme(Color primary, Color secondary, Color tertiary) {
    TextStyle style(double size, FontWeight weight, {double? tracking, Color? color, double? height}) {
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: tracking,
        height: height,
        color: color ?? primary,
      );
    }

    return TextTheme(
      // Large Title — 34/700, usado nos cabeçalhos de topo das abas.
      headlineLarge: style(34, FontWeight.w700, tracking: -0.6, height: 1.15),
      // Title 1 — 28/700
      headlineMedium: style(28, FontWeight.w700, tracking: -0.4, height: 1.18),
      // Title 2 — 22/700
      headlineSmall: style(22, FontWeight.w700, tracking: -0.3, height: 1.2),
      // Title 3 — 20/600
      titleLarge: style(20, FontWeight.w600, tracking: -0.2, height: 1.25),
      // Headline — 17/600
      titleMedium: style(17, FontWeight.w600, tracking: -0.2, height: 1.3),
      // Callout — 16/600
      titleSmall: style(16, FontWeight.w600, tracking: -0.1, height: 1.3),
      // Body — 17/400
      bodyLarge: style(17, FontWeight.w400, tracking: -0.2, height: 1.35, color: primary),
      // Subhead — 15/400
      bodyMedium: style(15, FontWeight.w400, tracking: -0.1, height: 1.35, color: secondary),
      // Footnote — 13/400
      bodySmall: style(13, FontWeight.w400, height: 1.3, color: secondary),
      // Headline (peso de botão) — 15/600
      labelLarge: style(15, FontWeight.w600, tracking: -0.1),
      // Caption 1 — 12/500, uppercase em cabeçalhos de seção
      labelMedium: style(12, FontWeight.w600, tracking: 0.2, color: tertiary),
      // Caption 2 — 11/500
      labelSmall: style(11, FontWeight.w500, tracking: 0.1, color: tertiary),
    );
  }
}
