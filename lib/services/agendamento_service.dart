import '../models/agendamento.dart';
import 'api_client.dart';

class AgendamentoService {
  final ApiClient _client = ApiClient();

  Future<List<Agendamento>> listar() async {
    final resposta = await _client.get('/agendamentos') as List<dynamic>;
    final lista = resposta.map((e) => Agendamento.fromJson(e as Map<String, dynamic>)).toList();
    lista.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return lista;
  }

  Future<Agendamento> criar({
    required String petId,
    required String servicoId,
    required String funcionarioId,
    required DateTime dateTime,
    String? observacoes,
  }) async {
    final resposta = await _client.post('/agendamentos', {
      'fk_id_pet': int.parse(petId),
      'fk_id_servico': int.parse(servicoId),
      'fk_id_funcionario': int.parse(funcionarioId),
      'data_agendamento': _formatarData(dateTime),
      'horario': _formatarHora(dateTime),
      if (observacoes != null && observacoes.isNotEmpty) 'observacao': observacoes,
    });
    return Agendamento.fromJson(resposta as Map<String, dynamic>);
  }

  Future<void> cancelar(String id) {
    return _client.patch('/agendamentos/$id/cancelar');
  }

  String _formatarData(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatarHora(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
