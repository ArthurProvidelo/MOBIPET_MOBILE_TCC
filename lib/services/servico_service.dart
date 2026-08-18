import '../models/servico.dart';
import 'api_client.dart';

class ServicoService {
  final ApiClient _client = ApiClient();

  Future<List<Servico>> listar() async {
    final resposta = await _client.get('/servicos') as List<dynamic>;
    return resposta.map((e) => Servico.fromJson(e as Map<String, dynamic>)).toList();
  }
}
