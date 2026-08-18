import 'package:flutter/material.dart';
import '../models/servico.dart';
import '../services/servico_service.dart';

class ServicosProvider extends ChangeNotifier {
  final ServicoService _service = ServicoService();

  List<Servico> _servicos = [];
  bool _carregando = false;

  List<Servico> get servicos => _servicos;
  bool get carregando => _carregando;

  Servico? porId(String id) {
    try {
      return _servicos.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _servicos = await _service.listar();
    _carregando = false;
    notifyListeners();
  }
}
