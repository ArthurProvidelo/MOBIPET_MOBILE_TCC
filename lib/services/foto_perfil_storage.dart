import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Guarda a foto de perfil localmente (a API ainda não tem upload).
///
/// O arquivo fica em `<documentos>/foto_perfil_<idCliente>.jpg`, então
/// sobrevive ao fechar o app e é isolado por usuário. Em web, onde não há
/// sistema de arquivos, todas as operações viram no-op.
class FotoPerfilStorage {
  Future<File?> carregar(String userId) async {
    if (kIsWeb) return null;
    final arquivo = await _arquivoDe(userId);
    return arquivo.existsSync() ? arquivo : null;
  }

  Future<File?> salvar(String userId, XFile origem) async {
    if (kIsWeb) return null;
    final arquivo = await _arquivoDe(userId);
    await arquivo.writeAsBytes(await origem.readAsBytes(), flush: true);
    return arquivo;
  }

  Future<void> remover(String userId) async {
    if (kIsWeb) return;
    final arquivo = await _arquivoDe(userId);
    if (arquivo.existsSync()) await arquivo.delete();
  }

  Future<File> _arquivoDe(String userId) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/foto_perfil_$userId.jpg');
  }
}
