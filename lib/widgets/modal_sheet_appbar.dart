import 'package:flutter/material.dart';

/// AppBar no padrão das folhas modais do iOS — "Cancelar" à esquerda, título
/// curto centralizado e a ação principal como texto à direita (não um botão
/// preenchido), como em "Novo evento" ou "Novo contato" no iPhone. Usada nas
/// telas apresentadas como tarefa pontual (ver [AppPageRoute.modal]), no
/// lugar do bloco de botão gigante no rodapé.
PreferredSizeWidget modalSheetAppBar(
  BuildContext context, {
  required String title,
  required String actionLabel,
  required VoidCallback? onAction,
  required VoidCallback onCancel,
  bool loading = false,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    leading: TextButton(
      onPressed: onCancel,
      child: const Text('Cancelar'),
    ),
    leadingWidth: 96,
    title: Text(title),
    centerTitle: true,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 4),
        child: TextButton(
          onPressed: loading ? null : onAction,
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      ),
    ],
  );
}
