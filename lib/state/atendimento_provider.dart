import 'package:flutter/material.dart';
import '../models/atendimento.dart';
import '../services/atendimento_service.dart';

class AtendimentoProvider extends ChangeNotifier {
  final AtendimentoService _service = AtendimentoService();

  Atendimento? _atual;
  bool _carregando = false;
  bool _avancando = false;

  Atendimento? get atual => _atual;
  bool get carregando => _carregando;
  bool get avancando => _avancando;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _atual = await _service.atual();
    _carregando = false;
    notifyListeners();
  }

  Future<void> simularLeituraRfid() async {
    if (_atual == null || _atual!.isFinalizado || _avancando) return;
    _avancando = true;
    notifyListeners();
    _atual = await _service.avancarEtapa(_atual!.id);
    _avancando = false;
    notifyListeners();
  }
}
