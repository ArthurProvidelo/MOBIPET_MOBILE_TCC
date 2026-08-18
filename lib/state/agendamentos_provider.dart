import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';

class AgendamentosProvider extends ChangeNotifier {
  final AgendamentoService _service = AgendamentoService();

  List<Agendamento> _agendamentos = [];
  bool _carregando = false;

  List<Agendamento> get agendamentos => _agendamentos;
  bool get carregando => _carregando;

  List<Agendamento> get proximos => _agendamentos
      .where((a) => a.status == StatusAgendamento.agendado && a.dateTime.isAfter(DateTime.now()))
      .toList();

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _agendamentos = await _service.listar();
    _carregando = false;
    notifyListeners();
  }

  Future<void> criar({
    required String petId,
    required String servicoId,
    required String funcionarioId,
    required DateTime dateTime,
    String? observacoes,
  }) async {
    await _service.criar(
      petId: petId,
      servicoId: servicoId,
      funcionarioId: funcionarioId,
      dateTime: dateTime,
      observacoes: observacoes,
    );
    await carregar();
  }

  Future<void> cancelar(String id) async {
    await _service.cancelar(id);
    await carregar();
  }
}
