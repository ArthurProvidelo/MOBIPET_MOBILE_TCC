import 'package:flutter/widgets.dart';

/// Subconjunto do set Iconly (por piqo, gratuito) usado no app.
///
/// As fontes ficam em `assets/fonts/` e são registradas no `pubspec.yaml`.
/// Só os glifos realmente usados são declarados aqui — para adicionar outro,
/// pegue o codePoint no repositório do flutter_iconly (lib/src/iconly_*.dart)
/// lembrando que Light e Bold têm codePoints diferentes para alguns ícones.
class IconlyLight {
  IconlyLight._();

  static const IconData home = IconData(0xe036, fontFamily: 'IconlyLight');
  static const IconData heart = IconData(0xe034, fontFamily: 'IconlyLight');
  static const IconData calendar = IconData(0xe01c, fontFamily: 'IconlyLight');
  static const IconData profile = IconData(0xe04b, fontFamily: 'IconlyLight');
  static const IconData plus = IconData(0xe04a, fontFamily: 'IconlyLight');
}

class IconlyBold {
  IconlyBold._();

  static const IconData home = IconData(0xe035, fontFamily: 'IconlyBold');
  static const IconData heart = IconData(0xe033, fontFamily: 'IconlyBold');
  static const IconData calendar = IconData(0xe01c, fontFamily: 'IconlyBold');
  static const IconData profile = IconData(0xe04b, fontFamily: 'IconlyBold');
  static const IconData plus = IconData(0xe04a, fontFamily: 'IconlyBold');
}
