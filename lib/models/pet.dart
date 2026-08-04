/// Espécie do pet.
enum PetSpecies {
  dog('Cachorro'),
  cat('Gato'),
  other('Outro');

  const PetSpecies(this.label);

  final String label;

  static PetSpecies fromKey(String? key) {
    return PetSpecies.values.firstWhere(
      (PetSpecies s) => s.name == key,
      orElse: () => PetSpecies.dog,
    );
  }
}

/// Porte do pet.
enum PetSize {
  small('Pequeno'),
  medium('Médio'),
  large('Grande');

  const PetSize(this.label);

  final String label;

  static PetSize fromKey(String? key) {
    return PetSize.values.firstWhere(
      (PetSize s) => s.name == key,
      orElse: () => PetSize.medium,
    );
  }
}

/// Pet cadastrado pelo tutor.
class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.species,
    required this.size,
    required this.weightKg,
    this.gender = 'Macho',
    this.rfidTag,
    this.photoAsset,
    this.notes = '',
  });

  final String id;
  final String name;
  final String breed;
  final DateTime birthDate;
  final PetSpecies species;
  final PetSize size;
  final double weightKg;
  final String gender;
  final String? rfidTag;
  final String? photoAsset;
  final String notes;

  /// Idade em anos completos.
  int get ageInYears {
    final DateTime now = DateTime.now();
    int years = now.year - birthDate.year;
    final bool hadBirthday =
        now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) years--;
    return years < 0 ? 0 : years;
  }

  int get ageInMonths {
    final DateTime now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) months--;
    return months < 0 ? 0 : months;
  }

  /// Idade formatada de forma amigável ("3 anos", "8 meses").
  String get ageLabel {
    if (ageInYears >= 1) {
      return ageInYears == 1 ? '1 ano' : '$ageInYears anos';
    }
    final int months = ageInMonths;
    return months == 1 ? '1 mês' : '$months meses';
  }

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();

  Pet copyWith({
    String? name,
    String? breed,
    DateTime? birthDate,
    PetSpecies? species,
    PetSize? size,
    double? weightKg,
    String? gender,
    String? rfidTag,
    String? photoAsset,
    String? notes,
  }) {
    return Pet(
      id: id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      species: species ?? this.species,
      size: size ?? this.size,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      rfidTag: rfidTag ?? this.rfidTag,
      photoAsset: photoAsset ?? this.photoAsset,
      notes: notes ?? this.notes,
    );
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'].toString(),
      name: json['name'] as String,
      breed: json['breed'] as String? ?? '',
      birthDate: DateTime.parse(json['birth_date'] as String),
      species: PetSpecies.fromKey(json['species'] as String?),
      size: PetSize.fromKey(json['size'] as String?),
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
      gender: json['gender'] as String? ?? 'Macho',
      rfidTag: json['rfid_tag'] as String?,
      photoAsset: json['photo'] as String?,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'breed': breed,
      'birth_date': birthDate.toIso8601String(),
      'species': species.name,
      'size': size.name,
      'weight_kg': weightKg,
      'gender': gender,
      'rfid_tag': rfidTag,
      'photo': photoAsset,
      'notes': notes,
    };
  }
}
