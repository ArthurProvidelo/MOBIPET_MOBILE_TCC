import '../models/agendamento.dart';
import 'api_client.dart';

class AgendamentoService {
  final ApiClient _client = ApiClient();

  /// Histórico completo do cliente (qualquer status), usado pela tela de
  /// Agendamentos. `todos=1` faz o backend ignorar a janela de ±30 min que
  /// vale para os lembretes da Home.
  Future<List<Agendamento>> listar() async {
    final resposta = await _client.get('/agendamentos?todos=1') as List<dynamic>;
    final lista = resposta.map((e) => Agendamento.fromJson(e as Map<String, dynamic>)).toList();
    lista.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return lista;
  }

  /// Próximos agendamentos do cliente (pendentes e futuros), já filtrados e
  /// ordenados pelo backend em `GET /agendamentos/proximos`.
  Future<List<Agendamento>> proximos() async {
    final resposta = await _client.get('/agendamentos/proximos');
    final dados = resposta is Map<String, dynamic> ? resposta['agendamentos'] as List<dynamic>? ?? const [] : resposta as List<dynamic>;
    final lista = dados.map((e) => Agendamento.fromJson(e as Map<String, dynamic>)).toList();
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

  /// Exclui o agendamento definitivamente. Usado para limpar do histórico
  /// agendamentos já finalizados (Concluído) ou cancelados.
  Future<void> excluir(String id) {
    return _client.delete('/agendamentos/$id');
  }

  /// Agendamento "atual" do cliente: o que já está em atendimento (Banho)
  /// ou, na falta desse, o próximo pendente.
  Future<Agendamento?> atual() async {
    final resposta = await _client.get('/agendamentos/atual') as Map<String, dynamic>;
    final dados = resposta['agendamento'];
    return dados == null ? null : Agendamento.fromJson(dados as Map<String, dynamic>);
  }

  /// Atendimento em andamento (status Banho) de um pet específico, ou null.
  Future<Agendamento?> atualDoPet(String petId) async {
    final resposta = await _client.get('/pets/$petId/atendimento-atual') as Map<String, dynamic>;
    final dados = resposta['agendamento'];
    return dados == null ? null : Agendamento.fromJson(dados as Map<String, dynamic>);
  }

  /// Check-in: inicia o atendimento de um agendamento pendente (Pendente -> Banho).
  Future<Agendamento> iniciar(String id) async {
    final resposta = await _client.post('/agendamentos/$id/iniciar');
    return Agendamento.fromJson(resposta as Map<String, dynamic>);
  }

  /// Simula a leitura do cartão RFID, avançando para a próxima etapa
  /// (Banho -> Concluído).
  Future<Agendamento> avancar(String id) async {
    final resposta = await _client.post('/agendamentos/$id/avancar');
    return Agendamento.fromJson(resposta as Map<String, dynamic>);
  }

  String _formatarData(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatarHora(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
