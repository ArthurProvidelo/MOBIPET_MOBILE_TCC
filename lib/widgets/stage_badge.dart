import 'package:flutter/material.dart';
import '../models/atendimento.dart';
import '../theme/app_colors.dart';
import '../utils/stage_utils.dart';

class StageBadge extends StatelessWidget {
  final EtapaAtendimento etapa;

  const StageBadge({super.key, required this.etapa});

  @override
  Widget build(BuildContext context) {
    final color = etapa == EtapaAtendimento.finalizado ? AppColors.success : AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(StageUtils.iconeDe(etapa), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            StageUtils.labelDe(etapa),
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
