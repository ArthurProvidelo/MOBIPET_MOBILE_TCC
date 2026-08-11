import '../models/agendamento.dart';
import 'mock_data.dart';

class AgendamentoService {
  static const _delay = Duration(milliseconds: 500);

  final List<Agendamento> _agendamentos = List.of(MockData.agendamentos);

  Future<List<Agendamento>> listarAgendamentos(String donoId) async {
    await Future.delayed(_delay);
    return List.of(_agendamentos)..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<Agendamento> criarAgendamento(Agendamento agendamento) async {
    await Future.delayed(_delay);
    _agendamentos.add(agendamento);
    return agendamento;
  }

  Future<Agendamento> atualizarStatus(String id, StatusAgendamento status) async {
    await Future.delayed(_delay);
    final index = _agendamentos.indexWhere((a) => a.id == id);
    final atualizado = _agendamentos[index].copyWith(status: status);
    _agendamentos[index] = atualizado;
    return atualizado;
  }

  Future<void> cancelarAgendamento(String id) async {
    await atualizarStatus(id, StatusAgendamento.cancelado);
  }
}
