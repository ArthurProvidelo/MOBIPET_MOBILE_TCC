import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../theme/app_colors.dart';
import 'custom_card.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAcompanhar;

  const PetCard({
    super.key,
    required this.pet,
    required this.onTap,
    this.onEdit,
    this.onAcompanhar,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.surfaceSecondary),
            child: Icon(Icons.pets_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${pet.breed} · ${pet.especie}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: AppColors.textSecondary),
            ),
          if (onAcompanhar != null)
            IconButton(
              onPressed: onAcompanhar,
              icon: Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            )
          else if (onEdit == null)
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
