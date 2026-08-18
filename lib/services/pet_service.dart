import '../models/pet.dart';
import 'api_client.dart';

class PetService {
  final ApiClient _client = ApiClient();

  Future<List<Pet>> listar() async {
    final resposta = await _client.get('/pets') as List<dynamic>;
    return resposta.map((e) => Pet.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Pet> criar(Pet pet) async {
    final resposta = await _client.post('/pets', pet.toJson());
    return Pet.fromJson(resposta as Map<String, dynamic>);
  }

  Future<Pet> atualizar(Pet pet) async {
    final resposta = await _client.put('/pets/${pet.id}', pet.toJson());
    return Pet.fromJson(resposta as Map<String, dynamic>);
  }

  Future<void> remover(String id) {
    return _client.delete('/pets/$id');
  }
}
