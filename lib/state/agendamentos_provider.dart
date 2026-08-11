import 'package:flutter/foundation.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';
import '../services/mock_data.dart';

class AgendamentosProvider extends ChangeNotifier {
  final AgendamentoService _agendamentoService;

  AgendamentosProvider({AgendamentoService? agendamentoService})
      : _agendamentoService = agendamentoService ?? AgendamentoService();

  List<Agendamento> _agendamentos = [];
  bool _isLoading = false;

  List<Agendamento> get agendamentos => _agendamentos;
  bool get isLoading => _isLoading;

  List<Agendamento> get proximos => _agendamentos
      .where((a) => a.status == StatusAgendamento.agendado)
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  Future<void> carregar() async {
    _isLoading = true;
    notifyListeners();
    _agendamentos = await _agendamentoService.listarAgendamentos(MockData.donoId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> criar(Agendamento agendamento) async {
    final criado = await _agendamentoService.criarAgendamento(agendamento);
    _agendamentos = [..._agendamentos, criado];
    notifyListeners();
  }

  Future<void> cancelar(String id) async {
    final atualizado = await _agendamentoService.atualizarStatus(id, StatusAgendamento.cancelado);
    _agendamentos = _agendamentos.map((a) => a.id == id ? atualizado : a).toList();
    notifyListeners();
  }
}
