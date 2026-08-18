import 'package:flutter/material.dart';
import '../models/atendimento.dart';
import '../theme/app_colors.dart';
import '../utils/stage_utils.dart';

class StageBadge extends StatelessWidget {
  final EtapaAtendimento etapa;

  const StageBadge({super.key, required this.etapa});

  @override
  Widget build(BuildContext context) {
    final color = StageUtils.color(etapa);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(StageUtils.icon(etapa), size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            StageUtils.label(etapa),
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class StageProgressBar extends StatelessWidget {
  final double progresso;
  final int etapasConcluidas;
  final int totalEtapas;

  const StageProgressBar({
    super.key,
    required this.progresso,
    required this.etapasConcluidas,
    required this.totalEtapas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$etapasConcluidas de $totalEtapas etapas concluídas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${(progresso * 100).round()}%',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progresso),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}
