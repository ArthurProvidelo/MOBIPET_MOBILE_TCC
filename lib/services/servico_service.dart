import '../models/servico.dart';
import 'mock_data.dart';

class ServicoService {
  static const _delay = Duration(milliseconds: 400);

  Future<List<Servico>> listarServicos() async {
    await Future.delayed(_delay);
    return List.of(MockData.servicos);
  }

  Future<Servico?> obterServico(String id) async {
    await Future.delayed(_delay);
    try {
      return MockData.servicos.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
