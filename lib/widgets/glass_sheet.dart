import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_surface.dart';

/// Folha de ação no mesmo vidro do resto do app: flutua com uma margem em
/// vez de colar nas bordas da tela, ecoando a cápsula flutuante da tab bar.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: GlassSurface(
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 4),
              Builder(builder: builder),
            ],
          ),
        ),
      ),
    ),
  );
}
