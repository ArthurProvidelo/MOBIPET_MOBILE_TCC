import 'package:flutter/material.dart';
import '../models/agendamento.dart';

class EtapaServico {
  final String label;
  final IconData icon;

  const EtapaServico(this.label, this.icon);
}

/// Esteiras de etapas detalhadas por tipo de serviço, exibidas no
/// acompanhamento do atendimento (Home e página do pet).
///
/// A 1ª etapa (Pendente) e a última (Finalizado) espelham o status real do
/// agendamento retornado pela API (agendado/concluído). As etapas
/// intermediárias são uma simulação client-side do fluxo de check-in/RFID:
/// o backend hoje só conhece os 3 estados de `AgendamentoController::ETAPAS`,
/// então elas não são persistidas — apenas avançadas localmente a cada toque
/// em "Simular leitura RFID", entre o check-in e a chamada real que finaliza
/// o atendimento.
abstract class EtapasServico {
  static const _pendente = EtapaServico('Pendente', Icons.hourglass_empty_rounded);
  static const _finalizado = EtapaServico('Finalizado', Icons.check_circle_rounded);

  static const banhoComum = [
    _pendente,
    EtapaServico('Chegou o horário', Icons.alarm_on_rounded),
    EtapaServico('Check-in', Icons.login_rounded),
    EtapaServico('Secagem', Icons.air_rounded),
    EtapaServico('Perfume', Icons.spa_rounded),
    _finalizado,
  ];

  static const banhoPremium = [
    _pendente,
    EtapaServico('Banho', Icons.water_drop_rounded),
    EtapaServico('Secagem', Icons.air_rounded),
    EtapaServico('Tosa', Icons.content_cut_rounded),
    EtapaServico('Escovação', Icons.brush_rounded),
    EtapaServico('Corte de unhas', Icons.design_services_rounded),
    EtapaServico('Perfume', Icons.spa_rounded),
    _finalizado,
  ];

  static const tosaCompleta = [
    _pendente,
    EtapaServico('Em tosa', Icons.content_cut_rounded),
    EtapaServico('Últimos detalhes', Icons.auto_awesome_rounded),
    _finalizado,
  ];

  /// Esteira genérica usada quando o serviço não casa com nenhum tipo
  /// conhecido acima.
  static const padrao = [
    _pendente,
    EtapaServico('Em andamento', Icons.water_drop_rounded),
    _finalizado,
  ];

  /// Resolve a esteira pelo nome do serviço (ex: "Banho Premium", "Tosa
  /// completa"). Usa correspondência por texto pois a API ainda não expõe
  /// um identificador estruturado de tipo de serviço.
  static List<EtapaServico> resolver(String? nomeServico) {
    final nome = (nomeServico ?? '').toLowerCase();
    if (nome.contains('premium')) return banhoPremium;
    if (nome.contains('tosa')) return tosaCompleta;
    if (nome.contains('banho')) return banhoComum;
    return padrao;
  }
}

/// Progresso de um agendamento na esteira de etapas detalhada do seu
/// serviço, combinando o status real (backend) com a etapa local simulada
/// (`subEtapaLocal`) enquanto o atendimento está em andamento.
class ProgressoEtapas {
  final List<EtapaServico> etapas;
  final int indice;

  const ProgressoEtapas(this.etapas, this.indice);

  EtapaServico get etapaAtual => etapas[indice];
  int get totalEtapas => etapas.length;
  int get etapasConcluidas => indice + 1;
  double get progresso => etapasConcluidas / totalEtapas;

  /// true quando o próximo toque em "avançar" deve finalizar o atendimento
  /// de verdade (chamando a API), em vez de só avançar a etapa local.
  bool get proximaAcaoFinaliza => indice == etapas.length - 2;

  static ProgressoEtapas de(Agendamento agendamento, {required int subEtapaLocal}) {
    final etapas = EtapasServico.resolver(agendamento.servicoNome);
    final indice = switch (agendamento.status) {
      StatusAgendamento.agendado => 0,
      StatusAgendamento.emAndamento => subEtapaLocal.clamp(1, etapas.length - 2),
      StatusAgendamento.concluido => etapas.length - 1,
      StatusAgendamento.cancelado => 0,
    };
    return ProgressoEtapas(etapas, indice);
  }
}
