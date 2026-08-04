import 'package:flutter/material.dart';

/// Etapas do atendimento registradas a cada leitura do cartão RFID
/// (leitor conectado ao ESP32).
enum ServiceStage {
  checkIn(
    'Check-in',
    'Pet recebido e cartão RFID vinculado',
    Icons.login_rounded,
  ),
  bath('Banho', 'Banho com produtos adequados ao pelo', Icons.shower_rounded),
  drying(
    'Secagem',
    'Secagem com sopro e temperatura controlada',
    Icons.air_rounded,
  ),
  grooming(
    'Tosa',
    'Tosa conforme o padrão escolhido',
    Icons.content_cut_rounded,
  ),
  brushing(
    'Escovação',
    'Escovação e desembaraço dos pelos',
    Icons.brush_rounded,
  ),
  perfume(
    'Perfume',
    'Finalização com perfume hipoalergênico',
    Icons.auto_awesome_rounded,
  ),
  readyForPickup(
    'Pronto para retirada',
    'Seu pet está pronto! Pode buscá-lo',
    Icons.notifications_active_rounded,
  ),
  finished(
    'Finalizado',
    'Atendimento concluído e entregue',
    Icons.verified_rounded,
  );

  const ServiceStage(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;

  static ServiceStage fromKey(String? key) {
    return ServiceStage.values.firstWhere(
      (ServiceStage s) => s.name == key,
      orElse: () => ServiceStage.checkIn,
    );
  }

  /// Fluxo completo padrão do pet shop.
  static const List<ServiceStage> fullFlow = ServiceStage.values;
}
