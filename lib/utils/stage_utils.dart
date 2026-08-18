import 'package:flutter/material.dart';
import '../models/atendimento.dart';
import '../theme/app_colors.dart';

abstract class StageUtils {
  static String label(EtapaAtendimento etapa) {
    switch (etapa) {
      case EtapaAtendimento.checkIn:
        return 'Check-in';
      case EtapaAtendimento.banho:
        return 'Banho';
      case EtapaAtendimento.secagem:
        return 'Secagem';
      case EtapaAtendimento.tosa:
        return 'Tosa';
      case EtapaAtendimento.escovacao:
        return 'Escovação';
      case EtapaAtendimento.perfume:
        return 'Perfume';
      case EtapaAtendimento.prontoParaRetirada:
        return 'Pronto para retirada';
      case EtapaAtendimento.finalizado:
        return 'Finalizado';
    }
  }

  static IconData icon(EtapaAtendimento etapa) {
    switch (etapa) {
      case EtapaAtendimento.checkIn:
        return Icons.login_rounded;
      case EtapaAtendimento.banho:
        return Icons.water_drop_rounded;
      case EtapaAtendimento.secagem:
        return Icons.air_rounded;
      case EtapaAtendimento.tosa:
        return Icons.content_cut_rounded;
      case EtapaAtendimento.escovacao:
        return Icons.brush_rounded;
      case EtapaAtendimento.perfume:
        return Icons.spa_rounded;
      case EtapaAtendimento.prontoParaRetirada:
        return Icons.inventory_2_rounded;
      case EtapaAtendimento.finalizado:
        return Icons.check_circle_rounded;
    }
  }

  static Color color(EtapaAtendimento etapa) {
    if (etapa == EtapaAtendimento.finalizado) return AppColors.success;
    return AppColors.primary;
  }
}
