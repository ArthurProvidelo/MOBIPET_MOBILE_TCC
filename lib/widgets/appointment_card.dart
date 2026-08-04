import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../models/pet.dart';
import '../models/pet_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'pet_avatar.dart';
import 'status_badge.dart';

/// Card de agendamento (lista de agendamentos e resumo na Home).
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.pet,
    required this.service,
    this.onTap,
    this.onCancel,
  });

  final Appointment appointment;
  final Pet? pet;
  final PetService? service;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final AppointmentStatus status = appointment.status;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (pet != null) PetAvatar(pet: pet!, size: 46),
              if (pet != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      service?.name ?? 'Serviço',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pet?.name ?? 'Pet removido',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: status.label,
                color: status.color,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.event_rounded,
                  size: 17,
                  color: AppColors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Formatters.friendlyDateTime(appointment.dateTime),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (service != null) ...<Widget>[
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    service!.durationLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    Formatters.currency(service!.price),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onCancel != null && appointment.isActive) ...<Widget>[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, size: 17),
                label: const Text('Cancelar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
