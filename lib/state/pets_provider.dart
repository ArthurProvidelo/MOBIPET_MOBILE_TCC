import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../services/mock_data.dart';
import '../services/pet_service.dart';

class PetsProvider extends ChangeNotifier {
  final PetService _petService;

  PetsProvider({PetService? petService}) : _petService = petService ?? PetService();

  List<Pet> _pets = [];
  bool _isLoading = false;

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;

  Pet? porId(String id) {
    try {
      return _pets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> carregar() async {
    _isLoading = true;
    notifyListeners();
    _pets = await _petService.listarPets(MockData.donoId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> adicionar(Pet pet) async {
    await _petService.criarPet(pet);
    _pets = [..._pets, pet];
    notifyListeners();
  }

  Future<void> atualizar(Pet pet) async {
    await _petService.atualizarPet(pet);
    _pets = _pets.map((p) => p.id == pet.id ? pet : p).toList();
    notifyListeners();
  }

  Future<void> remover(String id) async {
    await _petService.excluirPet(id);
    _pets = _pets.where((p) => p.id != id).toList();
    notifyListeners();
  }
}
