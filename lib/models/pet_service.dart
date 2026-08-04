import 'package:flutter/material.dart';

import 'service_stage.dart';

/// Serviço oferecido pelo pet shop (Banho, Banho e Tosa, ...).
class PetService {
  const PetService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.stages,
    required this.icon,
    this.highlight = false,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;

  /// Etapas monitoradas pelo leitor RFID para este serviço.
  final List<ServiceStage> stages;
  final IconData icon;
  final bool highlight;

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes min';
    final int hours = durationMinutes ~/ 60;
    final int minutes = durationMinutes % 60;
    return minutes == 0 ? '${hours}h' : '${hours}h${minutes}min';
  }

  /// Ícones suportados no contrato da API (`icon: "bath" | "scissors" | ...`).
  static const Map<String, IconData> iconCatalog = <String, IconData>{
    'bath': Icons.shower_rounded,
    'scissors': Icons.content_cut_rounded,
    'spa': Icons.spa_rounded,
    'hygiene': Icons.clean_hands_rounded,
    'paw': Icons.pets_rounded,
  };

  static String iconKeyOf(IconData icon) {
    for (final MapEntry<String, IconData> entry in iconCatalog.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'paw';
  }

  factory PetService.fromJson(Map<String, dynamic> json) {
    return PetService(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      stages: (json['stages'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => ServiceStage.fromKey(e as String?))
          .toList(),
      icon: iconCatalog[json['icon'] as String? ?? 'paw'] ?? Icons.pets_rounded,
      highlight: json['highlight'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'stages': stages.map((ServiceStage s) => s.name).toList(),
      'icon': iconKeyOf(icon),
      'highlight': highlight,
    };
  }
}
