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

  /// true quando o último `simularLeituraRfid` mudou o status real no backend
  /// (check-in ou finalização), e não apenas uma etapa local. A Home usa isso
  /// para recarregar as telas que dependem do status (lista de agendamentos,
  /// pets).
  bool _ultimaAcaoMudouBackend = false;
  bool get ultimaAcaoMudouBackend => _ultimaAcaoMudouBackend;

  /// Avança a esteira de etapas: faz check-in (chamada real) ao sair de
  /// Pendente, avança etapas intermediárias localmente e finaliza o
  /// atendimento (chamada real) na última etapa antes de "Finalizado".
  ///
  /// Retorna `true` se a ação foi concluída sem erro; `false` se a API
  /// recusou/falhou (a mensagem fica em [erro]).
  Future<bool> simularLeituraRfid() async {
    final atual = _atual;
    if (atual == null || atual.isFinalizado || _avancando) return false;

    final progresso = ProgressoEtapas.de(atual, subEtapaLocal: _subEtapaLocal);

    _avancando = true;
    _erro = null;
    _ultimaAcaoMudouBackend = false;
    notifyListeners();
    try {
      if (atual.status == StatusAgendamento.agendado) {
        _atual = await _service.iniciar(atual.id);
        _subEtapaLocal = 1;
        _ultimaAcaoMudouBackend = true;
      } else if (progresso.proximaAcaoFinaliza) {
        _atual = await _service.avancar(atual.id);
        _subEtapaLocal = 0;
        _ultimaAcaoMudouBackend = true;
      } else {
        _subEtapaLocal = (_subEtapaLocal + 1).clamp(1, progresso.etapas.length - 2);
      }
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _avancando = false;
      notifyListeners();
    }
  }
}
