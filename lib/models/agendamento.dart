enum StatusAgendamento { agendado, concluido, cancelado }

class Agendamento {
  final String id;
  final String petId;
  final String servicoId;
  final DateTime dateTime;
  final StatusAgendamento status;
  final String? atendimentoId;

  const Agendamento({
    required this.id,
    required this.petId,
    required this.servicoId,
    required this.dateTime,
    required this.status,
    this.atendimentoId,
  });

  Agendamento copyWith({
    StatusAgendamento? status,
    String? atendimentoId,
  }) {
    return Agendamento(
      id: id,
      petId: petId,
      servicoId: servicoId,
      dateTime: dateTime,
      status: status ?? this.status,
      atendimentoId: atendimentoId ?? this.atendimentoId,
    );
  }
}
