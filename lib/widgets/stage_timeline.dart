import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../theme/app_colors.dart';
import '../utils/etapas_servico.dart';

class StageTimeline extends StatelessWidget {
  final Agendamento agendamento;
  final ProgressoEtapas progresso;

  const StageTimeline({super.key, required this.agendamento, required this.progresso});

  @override
  Widget build(BuildContext context) {
    final etapas = progresso.etapas;
    final etapaIndex = progresso.indice;

    return Column(
      children: List.generate(etapas.length, (index) {
        final etapa = etapas[index];
        final isLast = index == etapas.length - 1;
        final concluida = index <= etapaIndex;
        final atual = index == etapaIndex && !agendamento.isFinalizado;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _StageNode(
                    icon: concluida ? (atual ? etapa.icon : Icons.check_rounded) : etapa.icon,
                    concluida: concluida,
                    atual: atual,
                  ),
                  if (!isLast)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOut,
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: index < etapaIndex ? AppColors.primary : AppColors.border,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        etapa.label,
                        style: TextStyle(
                          fontWeight: concluida ? FontWeight.w600 : FontWeight.w500,
                          color: concluida ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      if (atual)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text('Em andamento', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// O nó de uma etapa na timeline. A etapa atual "respira" — um halo pulsa
/// suavemente ao redor dela — para deixar claro, à distância, onde o
/// atendimento está agora sem precisar ler o texto. É o único elemento do
/// app com esse tipo de loop contínuo, reservado de propósito para o
/// indicador ao vivo (a funcionalidade central do produto).
class _StageNode extends StatefulWidget {
  final IconData icon;
  final bool concluida;
  final bool atual;

  const _StageNode({required this.icon, required this.concluida, required this.atual});

  @override
  State<_StageNode> createState() => _StageNodeState();
}

class _StageNodeState extends State<_StageNode> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleColor = widget.concluida ? AppColors.primary : AppColors.border;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final node = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.atual ? 34 : 28,
      height: widget.atual ? 34 : 28,
      decoration: BoxDecoration(
        color: widget.concluida ? circleColor : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: widget.concluida ? circleColor : AppColors.border, width: 2),
      ),
      child: Icon(
        widget.icon,
        size: widget.atual ? 18 : 14,
        color: widget.concluida ? AppColors.white : AppColors.textSecondary,
      ),
    );

    if (!widget.atual || reduceMotion) return node;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22 + 0.2 * t),
                blurRadius: 10 + 6 * t,
                spreadRadius: 1 + 3 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: node,
    );
  }
}
