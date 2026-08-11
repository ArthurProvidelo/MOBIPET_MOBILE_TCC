class Pet {
  final String id;
  final String donoId;
  final String name;
  final String breed;
  final String age;
  final String gender;
  final double weight;
  final String birthDate;
  final String imageUrl;
  final String notes;

  const Pet({
    required this.id,
    required this.donoId,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    required this.birthDate,
    required this.imageUrl,
    this.notes = '',
  });

  Pet copyWith({
    String? name,
    String? breed,
    String? age,
    String? gender,
    double? weight,
    String? birthDate,
    String? imageUrl,
    String? notes,
  }) {
    return Pet(
      id: id,
      donoId: donoId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      birthDate: birthDate ?? this.birthDate,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }
}
