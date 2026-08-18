import 'package:flutter/material.dart';
import '../models/funcionario.dart';
import '../services/funcionario_service.dart';

class FuncionariosProvider extends ChangeNotifier {
  final FuncionarioService _service = FuncionarioService();

  List<Funcionario> _funcionarios = [];
  bool _carregando = false;

  List<Funcionario> get funcionarios => _funcionarios;
  bool get carregando => _carregando;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _funcionarios = await _service.listar();
    _carregando = false;
    notifyListeners();
  }
}
