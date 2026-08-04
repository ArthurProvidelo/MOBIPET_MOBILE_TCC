import 'package:flutter/material.dart';

import '../models/monitoring_session.dart';
import '../models/service_stage.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Timeline vertical das etapas do atendimento.
///
/// Etapas concluídas exibem o horário da leitura do cartão RFID; a etapa
/// atual pulsa suavemente e as futuras ficam esmaecidas.
class StageTimeline extends StatelessWidget {
  const StageTimeline({
    super.key,
    required this.session,
    this.compact = false,
    this.maxItems,
  });

  final MonitoringSession session;
  final bool compact;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final List<ServiceStage> stages = session.stages;
    final int done = session.completedCount;

    int start = 0;
    int end = stages.length;
    if (maxItems != null && stages.length > maxItems!) {
      start = (done - 1).clamp(0, stages.length - maxItems!);
      end = start + maxItems!;
    }

    final List<Widget> items = <Widget>[];
    for (int i = start; i < end; i++) {
      final ServiceStage stage = stages[i];
      final bool isDone = i < done;
      final bool isCurrent = i == done - 1;
      final bool isNext = i == done;
      items.add(
        _TimelineTile(
          stage: stage,
          isDone: isDone,
          isCurrent: isCurrent,
          isNext: isNext,
          isFirst: i == start,
          isLast: i == end - 1,
          time: session.completionTimeOf(stage),
          compact: compact,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.stage,
    required this.isDone,
    required this.isCurrent,
    required this.isNext,
    required this.isFirst,
    required this.isLast,
    required this.time,
    required this.compact,
  });

  final ServiceStage stage;
  final bool isDone;
  final bool isCurrent;
  final bool isNext;
  final bool isFirst;
  final bool isLast;
  final DateTime? time;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color accent = isCurrent
        ? AppColors.orange
        : isDone
        ? AppColors.blue
        : AppColors.divider;
    final Color labelColor = isDone || isNext
        ? AppColors.text
        : AppColors.textSecondary;
    final double dotSize = compact ? 30 : 38;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 2,
                height: isFirst ? 0 : 6,
                color: isDone ? AppColors.blue : AppColors.divider,
              ),
              _StageDot(
                stage: stage,
                size: dotSize,
                accent: accent,
                isDone: isDone,
                isCurrent: isCurrent,
                isNext: isNext,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AppColors.blue : AppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: compact ? 4 : 8,
                bottom: isLast ? 0 : (compact ? 14 : 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          stage.label,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: labelColor,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                        ),
                      ),
                      if (time != null)
                        Text(
                          Formatters.time(time!),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isCurrent
                                    ? AppColors.orange
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      else if (isNext)
                        Text(
                          'aguardando',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                  if (!compact) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      stage.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.stage,
    required this.size,
    required this.accent,
    required this.isDone,
    required this.isCurrent,
    required this.isNext,
  });

  final ServiceStage stage;
  final double size;
  final Color accent;
  final bool isDone;
  final bool isCurrent;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final Widget dot = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? (isCurrent ? AppColors.orange : AppColors.blue)
            : AppColors.white,
        border: Border.all(
          color: isNext ? AppColors.lightBlue : accent,
          width: isNext ? 2 : 1.4,
        ),
        boxShadow: isCurrent
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Icon(
        isDone && !isCurrent ? Icons.check_rounded : stage.icon,
        size: size * 0.5,
        color: isDone
            ? AppColors.white
            : (isNext ? AppColors.lightBlue : AppColors.textSecondary),
      ),
    );

    if (!isCurrent) return dot;
    return _PulseRing(color: AppColors.orange, size: size, child: dot);
  }
}

/// Anel pulsante discreto para destacar a etapa atual.
class _PulseRing extends StatefulWidget {
  const _PulseRing({
    required this.child,
    required this.color,
    required this.size,
  });

  final Widget child;
  final Color color;
  final double size;

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final double t = Curves.easeOut.transform(_controller.value);
              return Container(
                width: widget.size * (1 + t * 0.55),
                height: widget.size * (1 + t * 0.55),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.22 * (1 - t)),
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}
