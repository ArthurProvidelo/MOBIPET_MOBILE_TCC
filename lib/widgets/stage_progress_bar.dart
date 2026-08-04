import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barra de progresso animada com rótulo "x de y etapas concluídas".
class StageProgressBar extends StatelessWidget {
  const StageProgressBar({
    super.key,
    required this.completed,
    required this.total,
    this.onDark = false,
    this.showLabel = true,
    this.height = 10,
  });

  final int completed;
  final int total;
  final bool onDark;
  final bool showLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double value = total == 0 ? 0 : completed / total;
    final Color track = onDark
        ? AppColors.white.withValues(alpha: 0.25)
        : AppColors.divider;
    final Color labelColor = onDark
        ? AppColors.white.withValues(alpha: 0.92)
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showLabel) ...<Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '$completed de $total etapas concluídas',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: onDark ? AppColors.white : AppColors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double animated, Widget? child) {
              return Stack(
                children: <Widget>[
                  Container(height: height, color: track),
                  FractionallySizedBox(
                    widthFactor: animated.clamp(0.0, 1.0),
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        gradient: onDark
                            ? const LinearGradient(
                                colors: <Color>[
                                  AppColors.white,
                                  Color(0xFFFFE1B4),
                                ],
                              )
                            : AppColors.warmGradient,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
