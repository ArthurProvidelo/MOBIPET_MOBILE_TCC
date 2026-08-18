import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';

class PetsProvider extends ChangeNotifier {
  final PetService _service = PetService();

  List<Pet> _pets = [];
  bool _carregando = false;

  List<Pet> get pets => _pets;
  bool get carregando => _carregando;

  Pet? porId(String id) {
    try {
      return _pets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _pets = await _service.listar();
    _carregando = false;
    notifyListeners();
  }

  Future<void> adicionar(Pet pet) async {
    await _service.criar(pet);
    await carregar();
  }

  Future<void> atualizar(Pet pet) async {
    await _service.atualizar(pet);
    await carregar();
  }

  Future<void> remover(String id) async {
    await _service.remover(id);
    await carregar();
  }
}
