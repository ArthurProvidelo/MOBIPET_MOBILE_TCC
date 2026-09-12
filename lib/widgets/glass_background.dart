import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fundo com profundidade — gradiente suave + manchas de cor desfocadas
/// posicionadas atrás do conteúdo. É o que dá ao vidro (GlassSurface,
/// BlurSurface) algo para refratar: sem uma superfície com variação de cor
/// por trás, um `BackdropFilter` só borra uma cor lisa e não lê como vidro.
///
/// Estático (sem animação): as manchas são desenhadas uma vez, então o custo
/// é o de qualquer `BoxDecoration` — isto fica atrás de toda tela do app
/// (montado uma única vez em `MobipetApp`), então precisa ser barato.
class GlassBackground extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final List<GlassBlob> blobs;

  const GlassBackground({super.key, required this.child, required this.gradient, required this.blobs});

  /// Fundo ambiente do app: quase branco, com só uma sugestão de azul e
  /// laranja da marca — para não competir com o conteúdo em cima.
  factory GlassBackground.ambient({Key? key, required Widget child}) {
    return GlassBackground(
      key: key,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF6F8FC), Color(0xFFEFF3FA), Color(0xFFFBF4EC)],
        stops: [0.0, 0.55, 1.0],
      ),
      blobs: const [
        GlassBlob(alignment: Alignment(-1.1, -1.0), size: 420, color: AppColors.primaryLight, opacity: 0.16),
        GlassBlob(alignment: Alignment(1.2, -0.6), size: 340, color: AppColors.accent, opacity: 0.10),
        GlassBlob(alignment: Alignment(1.1, 1.2), size: 460, color: AppColors.primary, opacity: 0.12),
        GlassBlob(alignment: Alignment(-1.2, 1.1), size: 320, color: AppColors.accent, opacity: 0.08),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          for (final blob in blobs)
            Positioned.fill(
              child: Align(
                alignment: blob.alignment,
                child: Container(
                  width: blob.size,
                  height: blob.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        blob.color.withValues(alpha: blob.opacity),
                        blob.color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class GlassBlob {
  final Alignment alignment;
  final double size;
  final Color color;
  final double opacity;

  const GlassBlob({required this.alignment, required this.size, required this.color, required this.opacity});
}
