/// Etapas fixas da esteira de atendimento acionada pelas leituras do cartão
/// RFID no leitor conectado ao ESP32. Cada aproximação do cartão avança
/// automaticamente o pet para a próxima etapa.
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

/// Chaves usadas pela API Laravel para cada etapa (coluna `etapa_atual` /
/// `etapa`), na mesma ordem do enum acima.
const _chavesEtapa = {
  EtapaAtendimento.checkIn: 'check_in',
  EtapaAtendimento.banho: 'banho',
  EtapaAtendimento.secagem: 'secagem',
  EtapaAtendimento.tosa: 'tosa',
  EtapaAtendimento.escovacao: 'escovacao',
  EtapaAtendimento.perfume: 'perfume',
  EtapaAtendimento.prontoParaRetirada: 'pronto_retirada',
  EtapaAtendimento.finalizado: 'finalizado',
};

EtapaAtendimento etapaAtendimentoFromChave(String chave) {
  return _chavesEtapa.entries.firstWhere((e) => e.value == chave).key;
}

String etapaAtendimentoParaChave(EtapaAtendimento etapa) => _chavesEtapa[etapa]!;

class EtapaTimestamp {
  final EtapaAtendimento etapa;
  final DateTime concluidaEm;

  const EtapaTimestamp({required this.etapa, required this.concluidaEm});

  factory EtapaTimestamp.fromJson(Map<String, dynamic> json) {
    return EtapaTimestamp(
      etapa: etapaAtendimentoFromChave(json['etapa'] as String),
      concluidaEm: DateTime.parse(json['concluida_em'] as String),
    );
  }
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

  factory Atendimento.fromJson(Map<String, dynamic> json) {
    final etapasJson = (json['etapas'] as List<dynamic>?) ?? const [];

    return Atendimento(
      id: json['id_atendimento'].toString(),
      petId: json['fk_id_pet'].toString(),
      servicoId: json['fk_id_servico'].toString(),
      agendamentoId: json['fk_id_agendamento']?.toString(),
      etapaAtual: etapaAtendimentoFromChave(json['etapa_atual'] as String),
      historico: etapasJson.map((e) => EtapaTimestamp.fromJson(e as Map<String, dynamic>)).toList(),
      iniciadoEm: DateTime.parse(json['iniciado_em'] as String),
      finalizadoEm: json['finalizado_em'] != null ? DateTime.parse(json['finalizado_em'] as String) : null,
    );
  }

  int get etapaIndex => EtapaAtendimento.values.indexOf(etapaAtual);

  int get totalEtapas => EtapaAtendimento.values.length;

  int get etapasConcluidas => etapaIndex + 1;

  double get progresso => etapasConcluidas / totalEtapas;

  bool get isFinalizado => etapaAtual == EtapaAtendimento.finalizado;

  DateTime? timestampDe(EtapaAtendimento etapa) {
    for (final t in historico) {
      if (t.etapa == etapa) return t.concluidaEm;
    }
    return null;
  }
}
