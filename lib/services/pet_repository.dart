import 'package:flutter/foundation.dart';

import '../models/pet.dart';
import 'mock_data.dart';

/// Repositório de pets em memória.
///
/// Equivale aos endpoints `GET/POST/PUT/DELETE /api/pets` da futura
/// API Laravel.
class PetRepository extends ChangeNotifier {
  final List<Pet> _pets = MockData.pets();
  bool _loading = false;

  List<Pet> get pets => List<Pet>.unmodifiable(_pets);

  bool get isLoading => _loading;

  bool get isEmpty => _pets.isEmpty;

  static const Duration _latency = Duration(milliseconds: 700);

  Pet? byId(String? id) {
    if (id == null) return null;
    for (final Pet pet in _pets) {
      if (pet.id == id) return pet;
    }
    return null;
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await Future<void>.delayed(_latency);
    _loading = false;
    notifyListeners();
  }

  Future<Pet> create(Pet pet) async {
    await Future<void>.delayed(_latency);
    final Pet created = pet.copyWith();
    _pets.add(created);
    notifyListeners();
    return created;
  }

  Future<Pet> update(Pet pet) async {
    await Future<void>.delayed(_latency);
    final int index = _pets.indexWhere((Pet p) => p.id == pet.id);
    if (index >= 0) {
      _pets[index] = pet;
      notifyListeners();
    }
    return pet;
  }

  Future<void> delete(String id) async {
    await Future<void>.delayed(_latency);
    _pets.removeWhere((Pet p) => p.id == id);
    notifyListeners();
  }

  String nextId() => DateTime.now().millisecondsSinceEpoch.toString();
}
