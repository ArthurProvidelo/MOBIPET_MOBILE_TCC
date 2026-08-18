class Pet {
  final String id;
  final String donoId;
  final String name;
  final String especie;
  final String breed;
  final String porte;
  final String birthDate;
  final String status;

  const Pet({
    required this.id,
    required this.donoId,
    required this.name,
    required this.especie,
    required this.breed,
    required this.porte,
    required this.birthDate,
    this.status = 'Aguardando atendimento',
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id_pet'].toString(),
      donoId: json['fk_id_cliente'].toString(),
      name: json['nome'] as String,
      especie: json['especie'] as String,
      breed: json['raca'] as String,
      porte: json['porte'] as String,
      birthDate: (json['data_nascimento'] as String).split('T').first,
      status: json['status'] as String? ?? 'Aguardando atendimento',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': name,
      'especie': especie,
      'raca': breed,
      'porte': porte,
      'data_nascimento': birthDate,
    };
  }

  Pet copyWith({
    String? name,
    String? especie,
    String? breed,
    String? porte,
    String? birthDate,
  }) {
    return Pet(
      id: id,
      donoId: donoId,
      name: name ?? this.name,
      especie: especie ?? this.especie,
      breed: breed ?? this.breed,
      porte: porte ?? this.porte,
      birthDate: birthDate ?? this.birthDate,
      status: status,
    );
  }
}
