import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet.dart';
import '../services/pet_foto_storage.dart';
import '../services/pet_service.dart';

class PetsProvider extends ChangeNotifier {
  final PetService _service = PetService();
  final PetFotoStorage _fotoStorage = PetFotoStorage();

  List<Pet> _pets = [];
  final Map<String, File> _fotos = {};
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

  File? fotoDe(String petId) => _fotos[petId];

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _pets = await _service.listar();
    for (final pet in _pets) {
      final foto = await _fotoStorage.carregar(pet.id);
      if (foto != null) {
        _fotos[pet.id] = foto;
      } else {
        _fotos.remove(pet.id);
      }
    }
    _carregando = false;
    notifyListeners();
  }

  Future<Pet> adicionar(Pet pet) async {
    final criado = await _service.criar(pet);
    await carregar();
    return criado;
  }

  Future<void> atualizar(Pet pet) async {
    await _service.atualizar(pet);
    await carregar();
  }

  Future<void> remover(String id) async {
    await _service.remover(id);
    await _fotoStorage.remover(id);
    _fotos.remove(id);
    await carregar();
  }

  /// Define (ou remove, se [imagem] for null) a foto de um pet. Guardada
  /// apenas localmente por enquanto — ver [PetFotoStorage].
  Future<bool> definirFoto(String petId, XFile? imagem) async {
    if (imagem == null) {
      await _fotoStorage.remover(petId);
      _fotos.remove(petId);
      notifyListeners();
      return true;
    }
    final arquivo = await _fotoStorage.salvar(petId, imagem);
    if (arquivo == null) return false;
    _fotos[petId] = arquivo;
    notifyListeners();
    return true;
  }
}
