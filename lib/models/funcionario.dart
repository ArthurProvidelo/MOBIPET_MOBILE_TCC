class Funcionario {
  final String id;
  final String nome;
  final String cargo;

  const Funcionario({required this.id, required this.nome, required this.cargo});

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      id: json['id_funcionario'].toString(),
      nome: json['nome'] as String,
      cargo: json['cargo'] as String? ?? '',
    );
  }
}
