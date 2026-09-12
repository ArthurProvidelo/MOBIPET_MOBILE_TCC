import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_card.dart';

/// Envolve blocos [Skeleton] com um brilho que varre da esquerda para a
/// direita em loop — o "shimmer" clássico de carregamento, feito à mão com
/// [ShaderMask] (sem depender de nenhum pacote externo).
///
/// Respeita "reduzir movimento": com a preferência ligada, os blocos ficam
/// parados na cor de base, sem o brilho animado.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              colors: [
                AppColors.surfaceSecondary,
                AppColors.border,
                AppColors.surfaceSecondary,
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1 - t * 3, 0),
              end: Alignment(1 - t * 3, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Um bloco retangular liso — a unidade básica de um esqueleto de
/// carregamento. Combine vários para desenhar o "fantasma" do layout real
/// (ex.: um círculo de avatar + duas barras de texto).
class Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const Skeleton({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  const Skeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: borderRadius),
    );
  }
}

/// Esqueleto de uma linha de lista: avatar circular + título + subtítulo.
class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Skeleton.circle(size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(width: 140, height: 15),
                SizedBox(height: 8),
                Skeleton(width: 90, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Fantasma" do cartão de atendimento atual (Home e Acompanhamento) —
/// mesmo raio e respiração do [CustomCard] real, para a tela não dar um
/// salto de layout quando o conteúdo chega.
class AtendimentoCardSkeleton extends StatelessWidget {
  const AtendimentoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Skeleton.circle(size: 52),
                SizedBox(width: 14),
                Skeleton(width: 120, height: 16),
              ],
            ),
            const SizedBox(height: 22),
            const Skeleton(height: 8, borderRadius: BorderRadius.all(Radius.circular(999))),
            const SizedBox(height: 18),
            const Skeleton(width: 130, height: 26, borderRadius: BorderRadius.all(Radius.circular(999))),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 14),
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(height: 24),
              Row(
                children: [
                  const Skeleton.circle(size: 28),
                  const SizedBox(width: 16),
                  Expanded(child: Skeleton(width: 100 + i * 20.0, height: 14)),
                ],
              ),
            ],
            const SizedBox(height: 22),
            const Skeleton(height: 48, borderRadius: BorderRadius.all(Radius.circular(14))),
          ],
        ),
      ),
    );
  }
}

/// Esqueleto de um cartão de detalhes: título + algumas linhas de campo,
/// no formato usado por [CustomCard] (mesmo raio, mesma respiração interna).
class CardSkeleton extends StatelessWidget {
  final int linhas;

  const CardSkeleton({super.key, this.linhas = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(width: 160, height: 18),
          const SizedBox(height: 18),
          for (var i = 0; i < linhas; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Skeleton(width: 100, height: 13),
                Skeleton(width: 70, height: 13),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
