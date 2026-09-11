import 'package:flutter/material.dart';
import '../utils/motion.dart';

/// Estilos de transição de página usados no app inteiro, escolhidos para que
/// façam sentido tanto indo quanto voltando:
///
/// - Navegação hierárquica comum (listar → detalhe, listar → sub-tela) usa o
///   `MaterialPageRoute` padrão: com [pageTransitionsTheme] configurado em
///   `AppTheme`, ele já desliza da direita ao entrar e desliza de volta para
///   a direita ao voltar — a metáfora natural de avançar/recuar numa pilha.
/// - [AppPageRoute.modal]: fluxos autocontidos (criar/editar algo). A tela
///   sobe a partir da base, como uma tarefa que se sobrepõe ao conteúdo; ao
///   salvar ou cancelar, ela desce de volta — reforça que é uma ação pontual
///   e não um novo nível da hierarquia.
/// - [AppPageRoute.fade]: trocas de sessão/contexto (splash, pós-login,
///   logout), onde não existe uma direção espacial de ida e volta — usar
///   slide aqui sugeriria uma hierarquia que não existe.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute._modal({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: AppCurves.springSoft,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(opacity: curved, child: child),
            );
          },
        );

  AppPageRoute._fade({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
        );

  /// Tela de tarefa autocontida (criar/editar algo): sobe do rodapé e volta
  /// a descer, sem sugerir avanço na hierarquia de navegação.
  factory AppPageRoute.modal(WidgetBuilder builder) => AppPageRoute._modal(builder: builder);

  /// Troca de sessão/contexto (splash, login bem-sucedido, logout): fade
  /// simétrico, sem direção — não faz sentido "vir da direita" aqui.
  factory AppPageRoute.fade(WidgetBuilder builder) => AppPageRoute._fade(builder: builder);
}
