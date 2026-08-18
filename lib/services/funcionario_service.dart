import '../models/funcionario.dart';
import 'api_client.dart';

class FuncionarioService {
  final ApiClient _client = ApiClient();

  Future<List<Funcionario>> listar() async {
    final resposta = await _client.get('/funcionarios') as List<dynamic>;
    return resposta.map((e) => Funcionario.fromJson(e as Map<String, dynamic>)).toList();
  }
}
