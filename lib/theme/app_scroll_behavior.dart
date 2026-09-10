import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Comportamento de rolagem único para o app inteiro.
///
/// Em vez do "brilho" de fim de lista do Android, toda rolagem devolve o
/// conteúdo com o efeito elástico do iOS — a mesma sensação de "puxar e
/// soltar" em qualquer plataforma. Também aceita arrastar com toque, mouse
/// e trackpad, e some com a barra de rolagem sobreposta no desktop.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Sem glow: o próprio "quique" da física já comunica o fim da lista.
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
