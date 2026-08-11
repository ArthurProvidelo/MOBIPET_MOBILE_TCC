import '../models/pet.dart';
import 'mock_data.dart';

class PetService {
  static const _delay = Duration(milliseconds: 500);

  final List<Pet> _pets = List.of(MockData.pets);

  Future<List<Pet>> listarPets(String donoId) async {
    await Future.delayed(_delay);
    return _pets.where((p) => p.donoId == donoId).toList();
  }

  Future<Pet?> obterPet(String id) async {
    await Future.delayed(_delay);
    try {
      return _pets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Pet> criarPet(Pet pet) async {
    await Future.delayed(_delay);
    _pets.add(pet);
    return pet;
  }

  Future<Pet> atualizarPet(Pet pet) async {
    await Future.delayed(_delay);
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) _pets[index] = pet;
    return pet;
  }

  Future<void> excluirPet(String id) async {
    await Future.delayed(_delay);
    _pets.removeWhere((p) => p.id == id);
  }
}
