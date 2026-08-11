import 'package:flutter/material.dart';
import '../models/atendimento.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatters.dart';
import '../utils/stage_utils.dart';

/// Timeline da esteira de atendimento RFID. Usada tanto em modo resumido
/// (Home) quanto em modo completo (Detalhes do Serviço) — ambas leem os
/// mesmos getters de `Atendimento`, então nunca divergem entre si.
class StageTimeline extends StatelessWidget {
  final Atendimento atendimento;
  final bool compact;

  const StageTimeline({super.key, required this.atendimento, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompact(context) : _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Etapa ${atendimento.etapaIndex + 1} de ${atendimento.totalEtapas}: ${StageUtils.labelDe(atendimento.etapaAtual)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
            ),
            Text(
              '${(atendimento.progresso * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: atendimento.progresso,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(
              atendimento.isFinalizado ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFull(BuildContext context) {
    final etapas = EtapaAtendimento.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${atendimento.etapaIndex + 1} de ${atendimento.totalEtapas} etapas concluídas',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
            ),
            Text(
              '${(atendimento.progresso * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: atendimento.progresso,
            minHeight: 10,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(
              atendimento.isFinalizado ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        for (int i = 0; i < etapas.length; i++) _buildStep(etapas[i], i, i == etapas.length - 1),
      ],
    );
  }

  Widget _buildStep(EtapaAtendimento etapa, int index, bool isLast) {
    final isConcluida = index < atendimento.etapaIndex || atendimento.isFinalizado && index <= atendimento.etapaIndex;
    final isAtual = index == atendimento.etapaIndex && !atendimento.isFinalizado;
    final timestamp = atendimento.timestampDe(etapa);

    final Color circleColor = isConcluida
        ? AppColors.success
        : isAtual
            ? AppColors.primary
            : AppColors.border;
    final Color lineColor = isConcluida ? AppColors.success : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isConcluida || isAtual ? circleColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: circleColor, width: 2),
                ),
                child: Icon(
                  isConcluida ? Icons.check : StageUtils.iconeDe(etapa),
                  size: 16,
                  color: isConcluida || isAtual ? Colors.white : AppColors.textSecondary,
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: lineColor)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StageUtils.labelDe(etapa),
                    style: TextStyle(
                      fontWeight: isAtual ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                      color: isAtual || isConcluida ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  if (timestamp != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        DateFormatters.hora(timestamp),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    )
                  else if (isAtual)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'Em andamento…',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
