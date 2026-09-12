import 'package:flutter/material.dart';

/// Ícone do tipo de pet. O Material não tem um glifo de gato (o mais
/// próximo, `cruelty_free`, é um coelho) — por isso o gato é desenhado à mão
/// aqui (cabeça + orelhas triangulares, o traço que mais diferencia um gato
/// de um cachorro num ícone pequeno).
class SpeciesIcon extends StatelessWidget {
  final String especie;
  final double size;
  final Color color;

  const SpeciesIcon({super.key, required this.especie, this.size = 24, required this.color});

  bool get _isGato => especie.trim().toLowerCase().startsWith('gato');
  bool get _isCao {
    final e = especie.trim().toLowerCase();
    return e.startsWith('cão') || e.startsWith('cao') || e.startsWith('cachorro');
  }

  @override
  Widget build(BuildContext context) {
    if (_isGato) {
      return CustomPaint(size: Size.square(size), painter: _CatFacePainter(color: color));
    }
    if (_isCao) {
      return Icon(Icons.pets_rounded, size: size, color: color);
    }
    return Icon(Icons.category_rounded, size: size, color: color);
  }
}

class _CatFacePainter extends CustomPainter {
  final Color color;

  _CatFacePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color;

    canvas.saveLayer(Offset.zero & size, Paint());

    // Cabeça.
    final centro = Offset(w * 0.5, h * 0.58);
    canvas.drawCircle(centro, w * 0.36, paint);

    // Orelhas triangulares — o traço que faz ler como gato, não coelho.
    final orelhaEsquerda = Path()
      ..moveTo(w * 0.18, h * 0.42)
      ..lineTo(w * 0.30, h * 0.02)
      ..lineTo(w * 0.46, h * 0.34)
      ..close();
    final orelhaDireita = Path()
      ..moveTo(w * 0.82, h * 0.42)
      ..lineTo(w * 0.70, h * 0.02)
      ..lineTo(w * 0.54, h * 0.34)
      ..close();
    canvas.drawPath(orelhaEsquerda, paint);
    canvas.drawPath(orelhaDireita, paint);

    // Olhos: buracos de verdade (blend clear), legíveis sobre qualquer fundo.
    final clear = Paint()..blendMode = BlendMode.clear;
    canvas.drawCircle(Offset(w * 0.38, h * 0.56), w * 0.05, clear);
    canvas.drawCircle(Offset(w * 0.62, h * 0.56), w * 0.05, clear);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CatFacePainter oldDelegate) => oldDelegate.color != color;
}
