import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/monitoring_session.dart';
import '../models/service_stage.dart';
import 'mock_data.dart';

/// Monitoramento do atendimento em tempo real.
///
/// No produto final, cada aproximação do cartão RFID no leitor conectado ao
/// ESP32 gera um evento no backend (`POST /api/rfid/read`) e o app recebe a
/// atualização por polling ou WebSocket. No protótipo, um [Timer] simula
/// essas leituras e o botão "Simular leitura RFID" força a próxima etapa.
class MonitoringService extends ChangeNotifier {
  MonitoringService() {
    _session = MockData.session();
    _startAutoReads();
  }

  late MonitoringSession _session;
  Timer? _timer;
  bool _lastReadJustHappened = false;

  /// Intervalo entre leituras simuladas do cartão.
  static const Duration autoReadInterval = Duration(seconds: 45);

  MonitoringSession? get session => _session.isFinished ? null : _session;

  MonitoringSession get lastSession => _session;

  bool get hasActiveSession => !_session.isFinished;

  /// Indica que uma etapa acabou de ser registrada (usado para animações).
  bool get justUpdated => _lastReadJustHappened;

  void _startAutoReads() {
    _timer?.cancel();
    _timer = Timer.periodic(autoReadInterval, (Timer timer) {
      if (_session.isFinished) {
        timer.cancel();
        return;
      }
      registerRfidRead();
    });
  }

  /// Registra a próxima etapa do fluxo, como faria uma leitura do cartão.
  ServiceStage? registerRfidRead() {
    final ServiceStage? next = _session.nextStage;
    if (next == null) return null;
    _session = _session.copyWith(
      events: <StageEvent>[
        ..._session.events,
        StageEvent(stage: next, time: DateTime.now()),
      ],
    );
    _lastReadJustHappened = true;
    notifyListeners();
    Future<void>.delayed(const Duration(seconds: 2), () {
      _lastReadJustHappened = false;
    });
    return next;
  }

  /// Reinicia o atendimento demonstrativo.
  void restartDemo() {
    _session = MockData.session();
    _startAutoReads();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
