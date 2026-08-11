import 'package:flutter/foundation.dart';
import '../models/atendimento.dart';
import '../services/atendimento_service.dart';
import '../services/mock_data.dart';

/// Estado compartilhado do atendimento em andamento. É a mesma instância
/// observada pela Home e pela tela Detalhes do Serviço, então o botão
/// "Simular leitura RFID" em qualquer uma delas mantém as duas em sincronia.
class AtendimentoProvider extends ChangeNotifier {
  final AtendimentoService _atendimentoService;

  AtendimentoProvider({AtendimentoService? atendimentoService})
      : _atendimentoService = atendimentoService ?? AtendimentoService();

  Atendimento? _atual;
  bool _isLoading = false;
  bool _isAvancando = false;

  Atendimento? get atual => _atual;
  bool get isLoading => _isLoading;
  bool get isAvancando => _isAvancando;

  Future<void> carregar() async {
    _isLoading = true;
    notifyListeners();
    _atual = await _atendimentoService.obterAtendimentoAtual(MockData.donoId);
    _isLoading = false;
    notifyListeners();
  }

  Future<Atendimento?> obter(String id) async {
    return _atendimentoService.obterAtendimento(id);
  }

  Future<void> simularLeituraRfid() async {
    if (_atual == null || _atual!.isFinalizado || _isAvancando) return;
    _isAvancando = true;
    notifyListeners();
    final atualizado = await _atendimentoService.avancarEtapa(_atual!.id);
    _atual = atualizado;
    _isAvancando = false;
    notifyListeners();
  }
}
