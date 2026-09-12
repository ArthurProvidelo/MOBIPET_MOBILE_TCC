import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Explosão de confete de um único disparo, sobreposta à tela inteira — o
/// "momento" reservado exclusivamente para quando um atendimento é
/// finalizado (a funcionalidade central do app). Deliberadamente não é usado
/// em nenhum outro lugar, para continuar sendo uma surpresa.
abstract class Celebration {
  static void play(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return;

    final overlay = Overlay.of(context);
    final controller = ConfettiController(duration: const Duration(milliseconds: 500));
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 28,
            maxBlastForce: 22,
            minBlastForce: 10,
            gravity: 0.35,
            colors: const [
              AppColors.white,
              Color(0xFF2D5D96),
              Color(0xFF58B8E8),
              Color(0xFFF59A23),
              Color(0xFF22C55E),
            ],
          ),
        ),
      ),
    );

    overlay.insert(entry);
    controller.play();
    Future.delayed(const Duration(milliseconds: 2000), () {
      entry.remove();
      controller.dispose();
    });
  }
}
