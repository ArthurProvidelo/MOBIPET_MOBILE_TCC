import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Guarda a foto de um pet localmente (a API ainda não tem upload de foto de
/// pet, no mesmo espírito de [FotoPerfilStorage]).
///
/// O arquivo fica em `<documentos>/foto_pet_<idPet>.jpg`. Em web, onde não há
/// sistema de arquivos, todas as operações viram no-op.
class PetFotoStorage {
  Future<File?> carregar(String petId) async {
    if (kIsWeb) return null;
    final arquivo = await _arquivoDe(petId);
    return arquivo.existsSync() ? arquivo : null;
  }

  Future<File?> salvar(String petId, XFile origem) async {
    if (kIsWeb) return null;
    final arquivo = await _arquivoDe(petId);
    await arquivo.writeAsBytes(await origem.readAsBytes(), flush: true);
    await FileImage(arquivo).evict();
    return arquivo;
  }

  Future<void> remover(String petId) async {
    if (kIsWeb) return;
    final arquivo = await _arquivoDe(petId);
    await FileImage(arquivo).evict();
    if (arquivo.existsSync()) await arquivo.delete();
  }

  Future<File> _arquivoDe(String petId) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/foto_pet_$petId.jpg');
  }
}
