import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Marca do MOBIPET: símbolo em gradiente + logotipo.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 72,
    this.showWordmark = true,
    this.onLightBackground = true,
  });

  final double size;
  final bool showWordmark;
  final bool onLightBackground;

  @override
  Widget build(BuildContext context) {
    final Color textColor = onLightBackground
        ? AppColors.blue
        : AppColors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppLogoMark(size: size, inverted: !onLightBackground),
        if (showWordmark) ...<Widget>[
          SizedBox(height: size * 0.22),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: 'MOBI',
                  style: TextStyle(
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ),
                TextSpan(
                  text: 'PET',
                  style: TextStyle(
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size * 0.04),
          Text(
            'MONITORAMENTO',
            style: TextStyle(
              fontSize: size * 0.15,
              fontWeight: FontWeight.w500,
              letterSpacing: size * 0.055,
              color: onLightBackground
                  ? AppColors.textSecondary
                  : AppColors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ],
    );
  }
}

/// Apenas o símbolo da marca.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 56, this.inverted = false});

  final double size;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: inverted ? null : AppColors.brandGradient,
        color: inverted ? AppColors.white : null,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blue.withValues(alpha: inverted ? 0.10 : 0.28),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(
        Icons.pets_rounded,
        size: size * 0.52,
        color: inverted ? AppColors.blue : AppColors.white,
      ),
    );
  }
}
