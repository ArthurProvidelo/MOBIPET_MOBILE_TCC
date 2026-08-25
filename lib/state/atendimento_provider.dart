import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';
import '../utils/etapas_servico.dart';

/// Acompanha o agendamento "atual" do cliente na Home (o que está em Banho
/// ou, na falta desse, o próximo Pendente) e a esteira de check-in/RFID.
class AtendimentoProvider extends ChangeNotifier {
  final AgendamentoService _service = AgendamentoService();

  Agendamento? _atual;
  int _subEtapaLocal = 0;
  bool _carregando = false;
  bool _avancando = false;
  String? _erro;

  Agendamento? get atual => _atual;
  bool get carregando => _carregando;
  bool get avancando => _avancando;
  String? get erro => _erro;

  /// Progresso na esteira de etapas detalhada do serviço do agendamento
  /// atual (null se não houver atendimento em andamento).
  ProgressoEtapas? get progresso =>
      _atual == null ? null : ProgressoEtapas.de(_atual!, subEtapaLocal: _subEtapaLocal);

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final novo = await _service.atual();
      if (novo?.id != _atual?.id) _subEtapaLocal = 0;
      _atual = novo;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Avança a esteira de etapas: faz check-in (chamada real) ao sair de
  /// Pendente, avança etapas intermediárias localmente e finaliza o
  /// atendimento (chamada real) na última etapa antes de "Finalizado".
  Future<void> simularLeituraRfid() async {
    final atual = _atual;
    if (atual == null || atual.isFinalizado || _avancando) return;

    final progresso = ProgressoEtapas.de(atual, subEtapaLocal: _subEtapaLocal);

    _avancando = true;
    _erro = null;
    notifyListeners();
    try {
      if (atual.status == StatusAgendamento.agendado) {
        _atual = await _service.iniciar(atual.id);
        _subEtapaLocal = 1;
      } else if (progresso.proximaAcaoFinaliza) {
        _atual = await _service.avancar(atual.id);
        _subEtapaLocal = 0;
      } else {
        _subEtapaLocal = (_subEtapaLocal + 1).clamp(1, progresso.etapas.length - 2);
      }
    } catch (e) {
      _erro = e.toString();
    } finally {
      _avancando = false;
      notifyListeners();
    }
  }
}
