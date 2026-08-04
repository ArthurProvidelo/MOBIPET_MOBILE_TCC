import 'service_stage.dart';

/// Registro de uma leitura do cartão RFID no leitor do ESP32.
class StageEvent {
  const StageEvent({required this.stage, required this.time});

  final ServiceStage stage;
  final DateTime time;

  factory StageEvent.fromJson(Map<String, dynamic> json) {
    return StageEvent(
      stage: ServiceStage.fromKey(json['stage'] as String?),
      time: DateTime.parse(json['read_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'stage': stage.name,
    'read_at': time.toIso8601String(),
  };
}

/// Atendimento em andamento monitorado pelo leitor RFID.
///
/// Cada aproximação do cartão avança uma etapa do fluxo do serviço.
class MonitoringSession {
  const MonitoringSession({
    required this.id,
    required this.petId,
    required this.serviceId,
    required this.rfidTag,
    required this.startedAt,
    required this.stages,
    required this.events,
    this.attendantName = 'Equipe MOBIPET',
  });

  final String id;
  final String petId;
  final String serviceId;
  final String rfidTag;
  final DateTime startedAt;

  /// Etapas previstas para o serviço, na ordem de execução.
  final List<ServiceStage> stages;

  /// Etapas já registradas pelo leitor RFID.
  final List<StageEvent> events;
  final String attendantName;

  int get completedCount => events.length;

  int get totalCount => stages.length;

  bool get isFinished => completedCount >= totalCount;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  int get progressPercent => (progress * 100).round();

  /// Etapa concluída mais recente.
  ServiceStage? get currentStage => events.isEmpty ? null : events.last.stage;

  /// Próxima etapa aguardando leitura do cartão.
  ServiceStage? get nextStage => isFinished ? null : stages[completedCount];

  DateTime? completionTimeOf(ServiceStage stage) {
    for (final StageEvent event in events) {
      if (event.stage == stage) return event.time;
    }
    return null;
  }

  bool isStageDone(ServiceStage stage) => completionTimeOf(stage) != null;

  /// Previsão de término considerando o ritmo médio das etapas concluídas.
  DateTime get estimatedEnd {
    const Duration fallback = Duration(minutes: 12);
    if (events.length < 2) {
      return startedAt.add(fallback * totalCount);
    }
    final Duration elapsed = events.last.time.difference(startedAt);
    final Duration average = Duration(
      milliseconds: elapsed.inMilliseconds ~/ (events.length - 1),
    );
    return events.last.time.add(average * (totalCount - completedCount));
  }

  MonitoringSession copyWith({List<StageEvent>? events}) {
    return MonitoringSession(
      id: id,
      petId: petId,
      serviceId: serviceId,
      rfidTag: rfidTag,
      startedAt: startedAt,
      stages: stages,
      events: events ?? this.events,
      attendantName: attendantName,
    );
  }

  factory MonitoringSession.fromJson(Map<String, dynamic> json) {
    return MonitoringSession(
      id: json['id'].toString(),
      petId: json['pet_id'].toString(),
      serviceId: json['service_id'].toString(),
      rfidTag: json['rfid_tag'] as String? ?? '',
      startedAt: DateTime.parse(json['started_at'] as String),
      stages: (json['stages'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => ServiceStage.fromKey(e as String?))
          .toList(),
      events: (json['events'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => StageEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      attendantName: json['attendant'] as String? ?? 'Equipe MOBIPET',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'pet_id': petId,
      'service_id': serviceId,
      'rfid_tag': rfidTag,
      'started_at': startedAt.toIso8601String(),
      'stages': stages.map((ServiceStage s) => s.name).toList(),
      'events': events.map((StageEvent e) => e.toJson()).toList(),
      'attendant': attendantName,
    };
  }
}
