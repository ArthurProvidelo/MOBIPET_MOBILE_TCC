import '../models/atendimento.dart';
import 'api_client.dart';

class AtendimentoService {
  final ApiClient _client = ApiClient();

  /// Atendimento em andamento mais recente entre todos os pets do cliente.
  Future<Atendimento?> atual() async {
    final resposta = await _client.get('/atendimentos/atual') as Map<String, dynamic>;
    final dados = resposta['atendimento'];
    return dados == null ? null : Atendimento.fromJson(dados as Map<String, dynamic>);
  }

  /// Atendimento em andamento de um pet específico (ou null).
  Future<Atendimento?> atualDoPet(String petId) async {
    final resposta = await _client.get('/pets/$petId/atendimento-atual') as Map<String, dynamic>;
    final dados = resposta['atendimento'];
    return dados == null ? null : Atendimento.fromJson(dados as Map<String, dynamic>);
  }

  /// Simula a leitura do cartão RFID no leitor conectado ao ESP32,
  /// avançando o pet para a próxima etapa da esteira de atendimento.
  Future<Atendimento> avancarEtapa(String atendimentoId) async {
    final resposta = await _client.post('/atendimentos/$atendimentoId/avancar');
    return Atendimento.fromJson(resposta as Map<String, dynamic>);
  }
}
