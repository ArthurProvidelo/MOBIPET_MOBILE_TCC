import '../models/atendimento.dart';
import '../utils/stage_utils.dart';
import 'mock_data.dart';

/// Simula o comportamento do leitor RFID conectado ao ESP32: cada leitura
/// avança o atendimento para a próxima etapa fixa da esteira.
class AtendimentoService {
  static const _delay = Duration(milliseconds: 350);

  final Map<String, Atendimento> _atendimentos = {
    MockData.atendimentoAtual.id: MockData.atendimentoAtual,
  };

  Future<Atendimento?> obterAtendimentoAtual(String donoId) async {
    await Future.delayed(_delay);
    try {
      return _atendimentos.values.firstWhere((a) => !a.isFinalizado);
    } catch (_) {
      return null;
    }
  }

  Future<Atendimento?> obterAtendimento(String id) async {
    await Future.delayed(_delay);
    return _atendimentos[id];
  }

  Future<Atendimento> avancarEtapa(String atendimentoId) async {
    await Future.delayed(_delay);
    final atual = _atendimentos[atendimentoId];
    if (atual == null) {
      throw StateError('Atendimento não encontrado');
    }
    final proxima = StageUtils.proximaEtapa(atual.etapaAtual);
    if (proxima == null) return atual;

    final novoHistorico = List.of(atual.historico)
      ..add(EtapaTimestamp(etapa: proxima, concluidaEm: DateTime.now()));

    final atualizado = atual.copyWith(
      etapaAtual: proxima,
      historico: novoHistorico,
      finalizadoEm: proxima == EtapaAtendimento.finalizado ? DateTime.now() : null,
    );

    _atendimentos[atendimentoId] = atualizado;
    return atualizado;
  }
}
