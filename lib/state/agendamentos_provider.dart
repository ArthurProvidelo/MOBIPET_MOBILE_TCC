import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';

class AgendamentosProvider extends ChangeNotifier {
  final AgendamentoService _service = AgendamentoService();

  List<Agendamento> _agendamentos = [];
  List<Agendamento> _proximos = [];
  bool _carregando = false;

  List<Agendamento> get agendamentos => _agendamentos;
  bool get carregando => _carregando;

  /// Próximos agendamentos vindos de `GET /agendamentos/proximos` (Laravel).
  List<Agendamento> get proximos => _proximos;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    final resultados = await Future.wait([
      _service.listar(),
      _service.proximos(),
    ]);
    _agendamentos = resultados[0];
    _proximos = resultados[1];
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

  Future<void> excluir(String id) async {
    await _service.excluir(id);
    await carregar();
  }
}
