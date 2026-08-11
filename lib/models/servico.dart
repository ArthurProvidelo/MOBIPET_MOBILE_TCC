import 'package:flutter/material.dart';

class Servico {
  final String id;
  final String nome;
  final Duration duracaoEstimada;
  final double preco;
  final String? descricao;
  final IconData icone;

  const Servico({
    required this.id,
    required this.nome,
    required this.duracaoEstimada,
    required this.preco,
    this.descricao,
    this.icone = Icons.pets,
  });
}
