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
                      color: concluida ? circleColor : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: concluida ? circleColor : AppColors.border, width: 2),
                      boxShadow: atual
                          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1)]
                          : null,
                    ),
                    child: Icon(
                      concluida ? (atual ? etapa.icon : Icons.check_rounded) : etapa.icon,
                      size: atual ? 18 : 14,
                      color: concluida ? AppColors.white : AppColors.textSecondary,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
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
