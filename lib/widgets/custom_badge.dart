import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../core/theme/app_colors.dart';

class CustomBadge extends StatelessWidget {
  final StatusAgendamento status;

  const CustomBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case StatusAgendamento.agendado:
        color = AppColors.info;
        label = 'Agendado';
        break;
      case StatusAgendamento.emAndamento:
        color = AppColors.warning;
        label = 'Em andamento';
        break;
      case StatusAgendamento.concluido:
        color = AppColors.success;
        label = 'Concluído';
        break;
      case StatusAgendamento.cancelado:
        color = AppColors.danger;
        label = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}