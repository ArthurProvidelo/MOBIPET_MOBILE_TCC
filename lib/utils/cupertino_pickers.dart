import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Seletores de data e hora em roda giratória, no estilo dos formulários do
/// iOS — substituem o calendário/relógio do Material por uma folha inferior
/// com o seletor nativo da Apple. Dentro do nosso `MaterialApp`, o
/// `CupertinoDatePicker` já herda automaticamente cor e brilho do tema
/// Material atual (claro/escuro), então não precisa de um `CupertinoApp`.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime minimumDate,
  required DateTime maximumDate,
}) {
  var selecionado = initialDate;
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return _PickerSheet(
        onConfirm: () => Navigator.of(sheetContext).pop(selecionado),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: initialDate,
          minimumDate: minimumDate,
          maximumDate: maximumDate,
          onDateTimeChanged: (value) => selecionado = value,
        ),
      );
    },
  );
}

Future<TimeOfDay?> showAppTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
}) {
  final agora = DateTime.now();
  var selecionado = DateTime(agora.year, agora.month, agora.day, initialTime.hour, initialTime.minute);
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return _PickerSheet(
        onConfirm: () => Navigator.of(sheetContext).pop(
          TimeOfDay(hour: selecionado.hour, minute: selecionado.minute),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: selecionado,
          use24hFormat: true,
          onDateTimeChanged: (value) => selecionado = value,
        ),
      );
    },
  );
}

class _PickerSheet extends StatelessWidget {
  final Widget child;
  final VoidCallback onConfirm;

  const _PickerSheet({required this.child, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onConfirm,
                child: const Text('Concluir', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          Divider(height: 1, color: AppColors.border),
          SizedBox(height: 220, child: child),
        ],
      ),
    );
  }
}
