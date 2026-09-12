import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/haptics.dart';
import 'glass_surface.dart';

class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) async {
    // Um toque ao abrir: a decisão pede atenção.
    Haptics.medium();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: GlassSurface(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Haptics.light();
                      Navigator.of(context).pop(false);
                    },
                    child: Text(cancelLabel),
                  ),
                  TextButton(
                    onPressed: () {
                      if (destructive) {
                        Haptics.error();
                      } else {
                        Haptics.success();
                      }
                      Navigator.of(context).pop(true);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: destructive ? AppColors.danger : AppColors.primary,
                    ),
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }
}
