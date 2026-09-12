import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../state/pets_provider.dart';
import '../theme/app_colors.dart';
import 'species_icon.dart';

/// Retrato de um pet: a foto dele, quando existe (ver [PetsProvider.fotoDe]),
/// ou um ícone do tipo (patinha para cão, rosto de gato para gato, etc. — ver
/// [SpeciesIcon]) como retrato "genérico" caso ele ainda não tenha uma foto.
class PetAvatar extends StatelessWidget {
  final Pet pet;
  final double size;
  final BorderRadius? borderRadius;

  const PetAvatar({super.key, required this.pet, this.size = 52, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final foto = context.watch<PetsProvider>().fotoDe(pet.id);
    final radius = borderRadius ?? BorderRadius.circular(size / 2);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: radius, color: AppColors.background),
      child: foto != null
          ? Image.file(foto, fit: BoxFit.cover, width: size, height: size)
          : Center(child: SpeciesIcon(especie: pet.especie, size: size * 0.46, color: AppColors.primary)),
    );
  }
}
