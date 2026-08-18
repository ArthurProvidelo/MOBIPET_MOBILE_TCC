import 'package:flutter/material.dart';
import '../models/atendimento.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatters.dart';
import '../utils/stage_utils.dart';

class StageTimeline extends StatelessWidget {
  final Atendimento atendimento;
  final bool compacto;

  const StageTimeline({super.key, required this.atendimento, this.compacto = false});

  @override
  Widget build(BuildContext context) {
    final etapas = EtapaAtendimento.values;
    final etapasVisiveis = compacto ? etapas.sublist(0, 4) : etapas;

    return Column(
      children: List.generate(etapasVisiveis.length, (index) {
        final etapa = etapasVisiveis[index];
        final isLast = index == etapasVisiveis.length - 1;
        final concluida = index <= atendimento.etapaIndex;
        final atual = etapa == atendimento.etapaAtual && !atendimento.isFinalizado;
        final timestamp = atendimento.timestampDe(etapa);
        final circleColor = concluida ? AppColors.primary : AppColors.border;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: atual ? 34 : 28,
                    height: atual ? 34 : 28,
                    decoration: BoxDecoration(
                      color: concluida ? circleColor : AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: concluida ? circleColor : AppColors.border, width: 2),
                      boxShadow: atual
                          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1)]
                          : null,
                    ),
                    child: Icon(
                      concluida ? (atual ? StageUtils.icon(etapa) : Icons.check_rounded) : StageUtils.icon(etapa),
                      size: atual ? 18 : 14,
                      color: concluida ? AppColors.white : AppColors.textSecondary,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: index < atendimento.etapaIndex ? AppColors.primary : AppColors.border,
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
                        StageUtils.label(etapa),
                        style: TextStyle(
                          fontWeight: concluida ? FontWeight.w600 : FontWeight.w500,
                          color: concluida ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      if (timestamp != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            DateFormatters.hora(timestamp),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      else if (atual)
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
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
