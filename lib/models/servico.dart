class Servico {
  final String id;
  final String nome;
  final String categoria;
  final Duration duracaoEstimada;
  final double preco;
  final String descricao;

  const Servico({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.duracaoEstimada,
    required this.preco,
    required this.descricao,
  });

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id_servico'].toString(),
      nome: json['nome'] as String,
      categoria: json['categoria'] as String? ?? '',
      duracaoEstimada: Duration(minutes: (json['duracao_estimada'] as num?)?.toInt() ?? 0),
      preco: double.parse(json['preco'].toString()),
      descricao: json['descricao'] as String? ?? '',
    );
  }

  String get duracaoFormatada {
    final minutos = duracaoEstimada.inMinutes;
    if (minutos < 60) return '$minutos min';
    final horas = minutos ~/ 60;
    final resto = minutos % 60;
    return resto == 0 ? '$horas h' : '$horas h $resto min';
  }
}
