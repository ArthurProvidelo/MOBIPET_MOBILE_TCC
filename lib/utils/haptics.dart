import 'package:flutter/services.dart';

/// Vocabulário tátil do app.
///
/// Centraliza as chamadas de [HapticFeedback] para que a "linguagem" de
/// vibração seja a mesma em todas as telas — como num app da Apple, onde
/// cada gesto tem um retorno físico proporcional ao seu peso:
///
/// - [light]  → toque comum (pressionar botão, abrir um card);
/// - [selection] → mudança discreta de estado (trocar de aba, marcar chip);
/// - [medium] → ação com consequência (confirmar, remover, concluir etapa);
/// - [success] / [error] → resultado de uma operação.
///
/// Em plataformas sem motor háptico (web, parte dos desktops) as chamadas
/// simplesmente não fazem nada — é seguro chamá-las em qualquer lugar.
abstract class Haptics {
  static void light() => HapticFeedback.lightImpact();

  static void medium() => HapticFeedback.mediumImpact();

  static void selection() => HapticFeedback.selectionClick();

  static void success() => HapticFeedback.mediumImpact();

  static void error() => HapticFeedback.heavyImpact();
}
