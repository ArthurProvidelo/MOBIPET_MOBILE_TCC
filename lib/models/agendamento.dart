enum StatusAgendamento { agendado, emAndamento, concluido, cancelado }

class Agendamento {
  final String id;
  final String petId;
  final String servicoId;
  final String funcionarioId;
  final DateTime dateTime;
  final StatusAgendamento status;
  final String? observacoes;
  final String? petNome;
  final String? servicoNome;
  final String? funcionarioNome;

  const Agendamento({
    required this.id,
    required this.petId,
    required this.servicoId,
    required this.funcionarioId,
    required this.dateTime,
    required this.status,
    this.observacoes,
    this.petNome,
    this.servicoNome,
    this.funcionarioNome,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    final data = (json['data_agendamento'] as String).split('T').first.split('-').map(int.parse).toList();
    final hora = (json['horario'] as String).split(':').map(int.parse).toList();
    final pet = json['pet'] as Map<String, dynamic>?;
    final servico = json['servico'] as Map<String, dynamic>?;
    final funcionario = json['funcionario'] as Map<String, dynamic>?;

    return Agendamento(
      id: json['id_agendamento'].toString(),
      petId: json['fk_id_pet'].toString(),
      servicoId: json['fk_id_servico'].toString(),
      funcionarioId: json['fk_id_funcionario']?.toString() ?? '',
      dateTime: DateTime(data[0], data[1], data[2], hora[0], hora[1]),
      status: _statusFromString(json['status_agendamento'] as String?),
      observacoes: json['observacao'] as String?,
      petNome: pet?['nome'] as String?,
      servicoNome: servico?['nome'] as String?,
      funcionarioNome: funcionario?['nome'] as String?,
    );
  }

  static StatusAgendamento _statusFromString(String? valor) {
    final normalizado = (valor ?? '').toLowerCase();
    if (normalizado.contains('cancel')) return StatusAgendamento.cancelado;
    if (normalizado.contains('andamento')) return StatusAgendamento.emAndamento;
    if (normalizado.contains('conclu') || normalizado.contains('finaliz')) return StatusAgendamento.concluido;
    return StatusAgendamento.agendado;
  }
}
