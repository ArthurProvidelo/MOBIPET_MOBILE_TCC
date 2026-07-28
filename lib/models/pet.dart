class Pet {
  final String id;
  final String name;
  final String breed;
  final String age;
  final String gender;
  final double weight;
  final String birthDate;
  final String imageUrl;
  final String notes;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    required this.birthDate,
    required this.imageUrl,
    this.notes = '',
  });
}