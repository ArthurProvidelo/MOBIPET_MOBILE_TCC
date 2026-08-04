import 'package:flutter/foundation.dart';

import '../models/appointment.dart';
import '../models/pet_service.dart';
import 'mock_data.dart';

/// Repositório de agendamentos e catálogo de serviços em memória.
///
/// Equivale a `GET /api/services` e `GET/POST/PATCH /api/appointments`.
class AppointmentRepository extends ChangeNotifier {
  final List<Appointment> _appointments = MockData.appointments();
  final List<PetService> _services = MockData.services();
  bool _loading = false;

  bool get isLoading => _loading;

  List<PetService> get services => List<PetService>.unmodifiable(_services);

  /// Todos os agendamentos, dos mais recentes para os mais antigos.
  List<Appointment> get all {
    final List<Appointment> list = List<Appointment>.of(_appointments);
    list.sort(
      (Appointment a, Appointment b) => b.dateTime.compareTo(a.dateTime),
    );
    return List<Appointment>.unmodifiable(list);
  }

  /// Agendamentos ativos, do mais próximo para o mais distante.
  List<Appointment> get upcoming {
    final List<Appointment> list =
        _appointments.where((Appointment a) => a.isActive).toList()..sort(
          (Appointment a, Appointment b) => a.dateTime.compareTo(b.dateTime),
        );
    return List<Appointment>.unmodifiable(list);
  }

  List<Appointment> get history {
    final List<Appointment> list =
        _appointments.where((Appointment a) => !a.isActive).toList()..sort(
          (Appointment a, Appointment b) => b.dateTime.compareTo(a.dateTime),
        );
    return List<Appointment>.unmodifiable(list);
  }

  List<Appointment> byPet(String petId) {
    final List<Appointment> list =
        _appointments.where((Appointment a) => a.petId == petId).toList()..sort(
          (Appointment a, Appointment b) => b.dateTime.compareTo(a.dateTime),
        );
    return List<Appointment>.unmodifiable(list);
  }

  Appointment? byId(String? id) {
    if (id == null) return null;
    for (final Appointment appointment in _appointments) {
      if (appointment.id == id) return appointment;
    }
    return null;
  }

  PetService? serviceById(String? id) {
    if (id == null) return null;
    for (final PetService service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  static const Duration _latency = Duration(milliseconds: 700);

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await Future<void>.delayed(_latency);
    _loading = false;
    notifyListeners();
  }

  Future<Appointment> create({
    required String petId,
    required String serviceId,
    required DateTime dateTime,
    String notes = '',
  }) async {
    await Future<void>.delayed(_latency);
    final Appointment appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: petId,
      serviceId: serviceId,
      dateTime: dateTime,
      status: AppointmentStatus.scheduled,
      notes: notes,
    );
    _appointments.add(appointment);
    notifyListeners();
    return appointment;
  }

  Future<void> cancel(String id) async {
    await Future<void>.delayed(_latency);
    final int index = _appointments.indexWhere((Appointment a) => a.id == id);
    if (index >= 0) {
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
      );
      notifyListeners();
    }
  }

  /// Remove os agendamentos de um pet excluído.
  void removeByPet(String petId) {
    _appointments.removeWhere((Appointment a) => a.petId == petId);
    notifyListeners();
  }

  /// Horários disponíveis para agendamento (mock).
  List<String> availableTimesFor(DateTime date) {
    const List<String> base = <String>[
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
    ];
    if (!_isToday(date)) return base;
    final DateTime now = DateTime.now();
    return base.where((String time) {
      final List<String> parts = time.split(':');
      final int hour = int.parse(parts.first);
      return hour > now.hour;
    }).toList();
  }

  bool _isToday(DateTime date) {
    final DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
