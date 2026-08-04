import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bloco com brilho animado usado durante os carregamentos.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 14,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: const <Color>[
                Color(0xFFEDF1F7),
                Color(0xFFF7FAFF),
                Color(0xFFEDF1F7),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Lista de cards "fantasma" exibida enquanto os dados carregam.
class LoadingList extends StatelessWidget {
  const LoadingList({super.key, this.itemCount = 3, this.itemHeight = 96});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(itemCount, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: <Widget>[
                const ShimmerBox(width: 60, height: 60, radius: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const ShimmerBox(width: 140, height: 14),
                      const SizedBox(height: 10),
                      const ShimmerBox(width: 90, height: 12),
                      const SizedBox(height: 10),
                      ShimmerBox(width: itemHeight * 1.6, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
