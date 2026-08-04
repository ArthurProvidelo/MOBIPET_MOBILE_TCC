import 'package:flutter/material.dart';

import '../models/monitoring_session.dart';
import '../models/pet.dart';
import '../models/pet_service.dart';
import '../models/service_stage.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'pet_avatar.dart';
import 'stage_progress_bar.dart';

/// Card em destaque da Home com o atendimento em andamento.
class CurrentServiceCard extends StatelessWidget {
  const CurrentServiceCard({
    super.key,
    required this.session,
    required this.pet,
    required this.service,
    this.onTap,
  });

  final MonitoringSession session;
  final Pet? pet;
  final PetService? service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ServiceStage? current = session.currentStage;
    final ServiceStage? next = session.nextStage;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -26,
                top: -22,
                child: Icon(
                  Icons.pets_rounded,
                  size: 128,
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const _LiveDot(),
                              const SizedBox(width: 7),
                              Text(
                                'Atendimento em andamento',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        if (pet != null)
                          PetAvatar(pet: pet!, size: 58, showBorder: true),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                pet?.name ?? 'Pet',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: AppColors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${service?.name ?? 'Serviço'} · ${pet?.breed ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  color: AppColors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  current?.icon ?? Icons.pets_rounded,
                                  size: 20,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      current?.label ?? 'Aguardando check-in',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: AppColors.white),
                                    ),
                                    if (next != null)
                                      Text(
                                        'Próxima etapa: ${next.label}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              if (session.events.isNotEmpty)
                                Text(
                                  Formatters.relative(session.events.last.time),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          StageProgressBar(
                            completed: session.completedCount,
                            total: session.totalCount,
                            onDark: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Previsão: ${Formatters.time(session.estimatedEnd)}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.nfc_rounded,
                          size: 15,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          session.rfidTag,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ponto pulsante indicando transmissão ao vivo.
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
