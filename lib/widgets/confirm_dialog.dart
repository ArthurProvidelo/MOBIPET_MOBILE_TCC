import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/haptics.dart';

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
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
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
    );
    return result ?? false;
  }
}
