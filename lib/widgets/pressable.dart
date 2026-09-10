import 'package:flutter/material.dart';

import '../utils/haptics.dart';

/// A resposta de toque padrão do app: o elemento "afunda" levemente (escala)
/// e devolve um toque háptico no instante do pressionar — o mesmo princípio
/// das células de lista e dos cards do iOS, onde o movimento *é* a
/// confirmação, sem respingo de tinta.
///
/// Respeita "Reduzir movimento" do sistema: com a opção ligada, o toque
/// háptico continua, mas a escala não anima.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Quanto o elemento encolhe enquanto pressionado (1.0 = sem encolher).
  final double pressedScale;

  /// Toque háptico ao pressionar. Desligue quando quem chama já dispara o seu.
  final bool haptic;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.haptic = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (!_enabled || value == _pressed) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _setPressed(true);
        if (widget.haptic && _enabled) Haptics.light();
      },
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed && !reduceMotion ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
