import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/foto_perfil_storage.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FotoPerfilStorage _fotoStorage = FotoPerfilStorage();

  Usuario? _usuario;
  File? _fotoPerfil;
  bool _carregando = false;
  bool _verificandoSessao = true;
  String? erro;

  Usuario? get usuario => _usuario;
  File? get fotoPerfil => _fotoPerfil;
  bool get autenticado => _usuario != null;
  bool get carregando => _carregando;

  /// true enquanto a Splash ainda está checando se há uma sessão salva.
  bool get verificandoSessao => _verificandoSessao;

  /// Chamado uma vez, na Splash: tenta restaurar a sessão a partir do token
  /// salvo localmente. Retorna true se havia uma sessão válida.
  Future<bool> tentarAutoLogin() async {
    _usuario = await _authService.usuarioAtual();
    await _carregarFotoPerfil();
    _verificandoSessao = false;
    notifyListeners();
    return autenticado;
  }

  Future<bool> login({required String email, required String senha}) async {
    _setCarregando(true);
    erro = null;
    try {
      _usuario = await _authService.login(email: email, senha: senha);
      await _carregarFotoPerfil();
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> criarConta({
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
    required String senha,
    required String cep,
    required String endereco,
  }) async {
    _setCarregando(true);
    erro = null;
    try {
      _usuario = await _authService.criarConta(
        nome: nome,
        cpf: cpf,
        email: email,
        telefone: telefone,
        senha: senha,
        cep: cep,
        endereco: endereco,
      );
      await _carregarFotoPerfil();
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> recuperarSenha({required String email}) async {
    _setCarregando(true);
    erro = null;
    try {
      await _authService.recuperarSenha(email: email);
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> atualizarPerfil({
    required String nome,
    required String email,
    required String telefone,
    required String cep,
    required String endereco,
  }) async {
    _setCarregando(true);
    erro = null;
    try {
      _usuario = await _authService.atualizarPerfil(
        nome: nome,
        email: email,
        telefone: telefone,
        cep: cep,
        endereco: endereco,
      );
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  /// Define (ou remove, se [imagem] for null) a foto de perfil. Guardada
  /// apenas localmente por enquanto — ver [FotoPerfilStorage].
  ///
  /// Retorna `true` quando a operação foi concluída. Retorna `false` se não há
  /// usuário logado ou se a plataforma não suporta armazenamento local da foto
  /// (ex: web), para que a tela possa avisar o usuário.
  Future<bool> definirFotoPerfil(XFile? imagem) async {
    final id = _usuario?.id;
    if (id == null) return false;
    if (imagem == null) {
      await _fotoStorage.remover(id);
      _fotoPerfil = null;
      notifyListeners();
      return true;
    }
    final arquivo = await _fotoStorage.salvar(id, imagem);
    _fotoPerfil = arquivo;
    notifyListeners();
    return arquivo != null;
  }

  Future<bool> alterarSenha({required String senhaAtual, required String novaSenha}) async {
    _setCarregando(true);
    erro = null;
    try {
      await _authService.alterarSenha(senhaAtual: senhaAtual, novaSenha: novaSenha);
      return true;
    } on ApiException catch (e) {
      erro = e.message;
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _usuario = null;
    _fotoPerfil = null;
    notifyListeners();
  }

  Future<void> _carregarFotoPerfil() async {
    final id = _usuario?.id;
    _fotoPerfil = id == null ? null : await _fotoStorage.carregar(id);
  }

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }
}
