import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../theme/app_colors.dart';
import 'etapas_servico.dart';

abstract class StageUtils {
  static Color color(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.concluido:
        return AppColors.success;
      case StatusAgendamento.cancelado:
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  /// Texto do botão de check-in/RFID de acordo com a etapa atual.
  static String rotuloAcao(Agendamento agendamento, ProgressoEtapas progresso) {
    switch (agendamento.status) {
      case StatusAgendamento.agendado:
        return 'Fazer check-in';
      case StatusAgendamento.emAndamento:
        return progresso.proximaAcaoFinaliza ? 'Finalizar atendimento' : 'Simular leitura RFID';
      case StatusAgendamento.concluido:
        return 'Atendimento concluído';
      case StatusAgendamento.cancelado:
        return 'Atendimento cancelado';
    }
  }
}
