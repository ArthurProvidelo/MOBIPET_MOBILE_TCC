import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../theme/app_colors.dart';

/// Avatar do pet: usa a foto cadastrada e, na ausência dela, um avatar
/// gerado com as cores da marca.
class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.pet,
    this.size = 60,
    this.showBorder = false,
  });

  final Pet pet;
  final double size;
  final bool showBorder;

  static const List<List<Color>> _palettes = <List<Color>>[
    <Color>[AppColors.blue, AppColors.lightBlue],
    <Color>[AppColors.orange, Color(0xFFF7C04A)],
    <Color>[Color(0xFF4C6FBF), Color(0xFF7FD0F5)],
    <Color>[Color(0xFF2E9E6B), Color(0xFF7FD3AE)],
  ];

  List<Color> get _palette =>
      _palettes[pet.id.hashCode.abs() % _palettes.length];

  @override
  Widget build(BuildContext context) {
    final Widget content = pet.photoAsset != null
        ? Image.asset(
            pet.photoAsset!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? s) =>
                _generated(),
          )
        : _generated();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: AppColors.white, width: size * 0.055)
            : null,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _palette.first.withValues(alpha: 0.28),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: ClipOval(child: content),
    );
  }

  Widget _generated() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _palette,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            right: -size * 0.16,
            bottom: -size * 0.16,
            child: Icon(
              Icons.pets_rounded,
              size: size * 0.62,
              color: AppColors.white.withValues(alpha: 0.22),
            ),
          ),
          Text(
            pet.initial,
            style: TextStyle(
              fontSize: size * 0.40,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
