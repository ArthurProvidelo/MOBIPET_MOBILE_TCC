enum StatusAgendamento { agendado, emAndamento, concluido, cancelado }

class Agendamento {
  final String id;
  final String petName;
  final String serviceName;
  final DateTime dateTime;
  final StatusAgendamento status;

  Agendamento({
    required this.id,
    required this.petName,
    required this.serviceName,
    required this.dateTime,
    required this.status,
  });
}