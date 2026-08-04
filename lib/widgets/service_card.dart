import 'package:flutter/material.dart';

import '../models/pet_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'app_card.dart';

/// Card de serviço do catálogo (grade da Home / seleção no agendamento).
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.selected = false,
    this.dense = false,
  });

  final PetService service;
  final VoidCallback? onTap;
  final bool selected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(dense ? 12 : 16),
      border: selected
          ? Border.all(color: AppColors.blue, width: 1.8)
          : Border.all(color: Colors.transparent, width: 1.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: dense ? 38 : 44,
                height: dense ? 38 : 44,
                decoration: BoxDecoration(
                  gradient: selected
                      ? AppColors.brandGradient
                      : LinearGradient(
                          colors: <Color>[
                            AppColors.lightBlue.withValues(alpha: 0.16),
                            AppColors.blue.withValues(alpha: 0.10),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  service.icon,
                  size: dense ? 19 : 22,
                  color: selected ? AppColors.white : AppColors.blue,
                ),
              ),
              const Spacer(),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.blue,
                  size: 22,
                )
              else if (service.highlight)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Mais pedido',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.orange,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: dense ? 10 : 14),
          Text(
            service.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              const Icon(
                Icons.schedule_rounded,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                service.durationLabel,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Spacer(),
              Text(
                Formatters.currency(service.price),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
