/// Etapas fixas da esteira de atendimento acionada pelas leituras do
/// cartão RFID no leitor conectado ao ESP32.
enum EtapaAtendimento {
  checkIn,
  banho,
  secagem,
  tosa,
  escovacao,
  perfume,
  prontoParaRetirada,
  finalizado,
}

class EtapaTimestamp {
  final EtapaAtendimento etapa;
  final DateTime concluidaEm;

  const EtapaTimestamp({required this.etapa, required this.concluidaEm});
}

class Atendimento {
  final String id;
  final String petId;
  final String servicoId;
  final String? agendamentoId;
  final EtapaAtendimento etapaAtual;
  final List<EtapaTimestamp> historico;
  final DateTime iniciadoEm;
  final DateTime? finalizadoEm;

  const Atendimento({
    required this.id,
    required this.petId,
    required this.servicoId,
    this.agendamentoId,
    required this.etapaAtual,
    required this.historico,
    required this.iniciadoEm,
    this.finalizadoEm,
  });

  int get etapaIndex => EtapaAtendimento.values.indexOf(etapaAtual);

  int get totalEtapas => EtapaAtendimento.values.length;

  double get progresso => (etapaIndex + 1) / totalEtapas;

  bool get isFinalizado => etapaAtual == EtapaAtendimento.finalizado;

  DateTime? timestampDe(EtapaAtendimento etapa) {
    for (final t in historico) {
      if (t.etapa == etapa) return t.concluidaEm;
    }
    return null;
  }

  Atendimento copyWith({
    EtapaAtendimento? etapaAtual,
    List<EtapaTimestamp>? historico,
    DateTime? finalizadoEm,
  }) {
    return Atendimento(
      id: id,
      petId: petId,
      servicoId: servicoId,
      agendamentoId: agendamentoId,
      etapaAtual: etapaAtual ?? this.etapaAtual,
      historico: historico ?? this.historico,
      iniciadoEm: iniciadoEm,
      finalizadoEm: finalizadoEm ?? this.finalizadoEm,
    );
  }
}
