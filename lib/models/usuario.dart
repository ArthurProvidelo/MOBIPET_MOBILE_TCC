class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? avatarUrl;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.avatarUrl,
  });

  String get primeiroNome => nome.split(' ').first;

  Usuario copyWith({
    String? nome,
    String? email,
    String? telefone,
    String? avatarUrl,
  }) {
    return Usuario(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
