import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/appointment.dart';
import '../models/monitoring_session.dart';
import '../models/pet.dart';
import '../models/pet_service.dart';
import '../models/service_stage.dart';

/// Fonte de dados fixa (mock) do protótipo.
///
/// Cada método equivale a um endpoint da futura API Laravel, para que a
/// troca da camada de dados não impacte as telas:
///
/// * [user]         -> `GET  /api/user`
/// * [pets]         -> `GET  /api/pets`
/// * [services]     -> `GET  /api/services`
/// * [appointments] -> `GET  /api/appointments`
/// * [session]      -> `GET  /api/monitoring/active`
class MockData {
  const MockData._();

  static const String demoEmail = 'joao.silva@email.com';
  static const String demoPassword = '123456';

  static AppUser user() {
    return AppUser(
      id: '1',
      name: 'João Silva',
      email: demoEmail,
      phone: '(11) 98765-4321',
      document: '123.456.789-00',
      address: 'Rua das Acácias, 245 - São Paulo/SP',
      memberSince: DateTime(2023, 3, 12),
    );
  }

  static List<Pet> pets() {
    final DateTime now = DateTime.now();
    return <Pet>[
      Pet(
        id: '1',
        name: 'Thor',
        breed: 'Golden Retriever',
        birthDate: DateTime(now.year - 3, 4, 18),
        species: PetSpecies.dog,
        size: PetSize.large,
        weightKg: 32.4,
        gender: 'Macho',
        rfidTag: 'RF-0A17C4',
        notes: 'Adora banho morno. Sensível ao secador muito quente.',
      ),
      Pet(
        id: '2',
        name: 'Luna',
        breed: 'Shih Tzu',
        birthDate: DateTime(now.year - 2, 9, 2),
        species: PetSpecies.dog,
        size: PetSize.small,
        weightKg: 6.1,
        gender: 'Fêmea',
        rfidTag: 'RF-2B93F1',
        notes: 'Tosa higiênica a cada 30 dias.',
      ),
      Pet(
        id: '3',
        name: 'Mel',
        breed: 'Labrador',
        birthDate: DateTime(now.year - 5, 1, 25),
        species: PetSpecies.dog,
        size: PetSize.large,
        weightKg: 28.8,
        gender: 'Fêmea',
        rfidTag: 'RF-7C51D9',
        notes: 'Pele sensível: usar shampoo hipoalergênico.',
      ),
    ];
  }

  static List<PetService> services() {
    return <PetService>[
      const PetService(
        id: '1',
        name: 'Banho',
        description:
            'Banho completo com shampoo neutro, secagem e escovação leve. '
            'Ideal para manutenção semanal da higiene do pet.',
        price: 65,
        durationMinutes: 60,
        icon: Icons.shower_rounded,
        highlight: true,
        stages: <ServiceStage>[
          ServiceStage.checkIn,
          ServiceStage.bath,
          ServiceStage.drying,
          ServiceStage.brushing,
          ServiceStage.perfume,
          ServiceStage.readyForPickup,
          ServiceStage.finished,
        ],
      ),
      const PetService(
        id: '2',
        name: 'Banho e Tosa',
        description:
            'Banho completo, tosa na máquina ou na tesoura conforme o padrão '
            'da raça, secagem, escovação e finalização com perfume.',
        price: 110,
        durationMinutes: 120,
        icon: Icons.content_cut_rounded,
        highlight: true,
        stages: ServiceStage.fullFlow,
      ),
      const PetService(
        id: '3',
        name: 'Hidratação',
        description:
            'Tratamento com máscara hidratante para pelos ressecados, '
            'devolvendo brilho e maciez à pelagem.',
        price: 90,
        durationMinutes: 90,
        icon: Icons.spa_rounded,
        stages: <ServiceStage>[
          ServiceStage.checkIn,
          ServiceStage.bath,
          ServiceStage.drying,
          ServiceStage.brushing,
          ServiceStage.perfume,
          ServiceStage.readyForPickup,
          ServiceStage.finished,
        ],
      ),
      const PetService(
        id: '4',
        name: 'Tosa Higiênica',
        description:
            'Tosa das áreas íntimas, patas e barriga, mantendo o pet limpo '
            'e confortável entre uma tosa completa e outra.',
        price: 55,
        durationMinutes: 45,
        icon: Icons.clean_hands_rounded,
        stages: <ServiceStage>[
          ServiceStage.checkIn,
          ServiceStage.grooming,
          ServiceStage.brushing,
          ServiceStage.perfume,
          ServiceStage.readyForPickup,
          ServiceStage.finished,
        ],
      ),
    ];
  }

  static List<Appointment> appointments() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return <Appointment>[
      Appointment(
        id: '1',
        petId: '1',
        serviceId: '2',
        dateTime: today.add(const Duration(hours: 9)),
        status: AppointmentStatus.inProgress,
        notes: 'Tosa da raça, deixar franja mais longa.',
      ),
      Appointment(
        id: '2',
        petId: '2',
        serviceId: '4',
        dateTime: today.add(const Duration(days: 2, hours: 14, minutes: 30)),
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: '3',
        petId: '3',
        serviceId: '1',
        dateTime: today.add(const Duration(days: 5, hours: 10)),
        status: AppointmentStatus.scheduled,
        notes: 'Usar shampoo hipoalergênico.',
      ),
      Appointment(
        id: '4',
        petId: '1',
        serviceId: '3',
        dateTime: today.subtract(const Duration(days: 12, hours: -11)),
        status: AppointmentStatus.completed,
      ),
      Appointment(
        id: '5',
        petId: '2',
        serviceId: '1',
        dateTime: today.subtract(const Duration(days: 21, hours: -15)),
        status: AppointmentStatus.completed,
      ),
      Appointment(
        id: '6',
        petId: '3',
        serviceId: '4',
        dateTime: today.subtract(const Duration(days: 30, hours: -9)),
        status: AppointmentStatus.cancelled,
        notes: 'Cancelado pelo tutor.',
      ),
    ];
  }

  /// Atendimento em andamento do Thor: três leituras de cartão já registradas.
  static MonitoringSession session() {
    final DateTime start = DateTime.now().subtract(const Duration(minutes: 48));
    final List<ServiceStage> stages = ServiceStage.fullFlow;
    return MonitoringSession(
      id: '1',
      petId: '1',
      serviceId: '2',
      rfidTag: 'RF-0A17C4',
      startedAt: start,
      attendantName: 'Carla Menezes',
      stages: stages,
      events: <StageEvent>[
        StageEvent(stage: stages[0], time: start),
        StageEvent(
          stage: stages[1],
          time: start.add(const Duration(minutes: 14)),
        ),
        StageEvent(
          stage: stages[2],
          time: start.add(const Duration(minutes: 33)),
        ),
      ],
    );
  }
}
