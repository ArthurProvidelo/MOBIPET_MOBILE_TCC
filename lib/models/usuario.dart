class Usuario {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String cpf;
  final String endereco;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.endereco,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id_cliente'].toString(),
      nome: json['nome'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String? ?? '',
      cpf: json['cpf'] as String? ?? '',
      endereco: json['endereco'] as String? ?? '',
    );
  }

  Usuario copyWith({
    String? nome,
    String? email,
    String? telefone,
    String? endereco,
  }) {
    return Usuario(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      cpf: cpf,
      endereco: endereco ?? this.endereco,
    );
  }
}
