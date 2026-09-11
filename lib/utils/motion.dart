import 'package:flutter/animation.dart';

/// Vocabulário de movimento do app: durações e curvas no espírito das molas
/// do iOS (leve overshoot e assentamento suave), sem depender de um pacote
/// de terceiros — são curvas Bézier calibradas para *parecerem* uma
/// `UISpring`, aplicadas com [AnimatedContainer]/[AnimatedScale] normais.
abstract class AppMotion {
  static const Duration quick = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 420);
}

abstract class AppCurves {
  /// A mola "padrão" do iOS: passa um pouco do alvo e volta. Ideal para
  /// elementos que aparecem/confirmam uma ação (ícone selecionado, check).
  static const Curve spring = Cubic(0.175, 0.885, 0.32, 1.275);

  /// Uma mola mais contida, quase sem overshoot — para transições de tela
  /// e elementos maiores, onde um salto grande ficaria exagerado.
  static const Curve springSoft = Cubic(0.34, 1.15, 0.64, 1.0);

  /// Easing padrão para fades/deslizamentos sem mola.
  static const Curve smooth = Curves.easeOutCubic;
}
