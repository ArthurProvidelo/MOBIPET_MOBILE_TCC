import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Situação de um agendamento.
enum AppointmentStatus {
  scheduled('Agendado', AppColors.lightBlue),
  inProgress('Em andamento', AppColors.orange),
  completed('Concluído', AppColors.success),
  cancelled('Cancelado', AppColors.danger);

  const AppointmentStatus(this.label, this.color);

  final String label;
  final Color color;

  static AppointmentStatus fromKey(String? key) {
    return AppointmentStatus.values.firstWhere(
      (AppointmentStatus s) => s.name == key,
      orElse: () => AppointmentStatus.scheduled,
    );
  }
}

/// Agendamento de um serviço para um pet.
class Appointment {
  const Appointment({
    required this.id,
    required this.petId,
    required this.serviceId,
    required this.dateTime,
    required this.status,
    this.notes = '',
  });

  final String id;
  final String petId;
  final String serviceId;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String notes;

  bool get isUpcoming =>
      status == AppointmentStatus.scheduled && dateTime.isAfter(DateTime.now());

  bool get isActive =>
      status == AppointmentStatus.scheduled ||
      status == AppointmentStatus.inProgress;

  Appointment copyWith({
    String? petId,
    String? serviceId,
    DateTime? dateTime,
    AppointmentStatus? status,
    String? notes,
  }) {
    return Appointment(
      id: id,
      petId: petId ?? this.petId,
      serviceId: serviceId ?? this.serviceId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'].toString(),
      petId: json['pet_id'].toString(),
      serviceId: json['service_id'].toString(),
      dateTime: DateTime.parse(json['scheduled_at'] as String),
      status: AppointmentStatus.fromKey(json['status'] as String?),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'pet_id': petId,
      'service_id': serviceId,
      'scheduled_at': dateTime.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }
}
