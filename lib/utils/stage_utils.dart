import 'package:flutter/material.dart';
import '../models/atendimento.dart';

abstract class StageUtils {
  static String labelDe(EtapaAtendimento etapa) {
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

  static IconData iconeDe(EtapaAtendimento etapa) {
    switch (etapa) {
      case EtapaAtendimento.checkIn:
        return Icons.badge_outlined;
      case EtapaAtendimento.banho:
        return Icons.shower_outlined;
      case EtapaAtendimento.secagem:
        return Icons.air_outlined;
      case EtapaAtendimento.tosa:
        return Icons.content_cut;
      case EtapaAtendimento.escovacao:
        return Icons.brush_outlined;
      case EtapaAtendimento.perfume:
        return Icons.spa_outlined;
      case EtapaAtendimento.prontoParaRetirada:
        return Icons.inventory_2_outlined;
      case EtapaAtendimento.finalizado:
        return Icons.check_circle_outline;
    }
  }

  static EtapaAtendimento? proximaEtapa(EtapaAtendimento etapaAtual) {
    final index = EtapaAtendimento.values.indexOf(etapaAtual);
    if (index >= EtapaAtendimento.values.length - 1) return null;
    return EtapaAtendimento.values[index + 1];
  }
}
