import 'dart:convert';

import 'package:http/http.dart' as http;

/// Endereço retornado pela API pública ViaCEP (https://viacep.com.br).
class EnderecoViaCep {
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  const EnderecoViaCep({
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory EnderecoViaCep.fromJson(Map<String, dynamic> json) {
    return EnderecoViaCep(
      logradouro: json['logradouro'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      localidade: json['localidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
    );
  }

  String get enderecoFormatado {
    final partes = [
      if (logradouro.isNotEmpty) logradouro,
      if (bairro.isNotEmpty) bairro,
      if (localidade.isNotEmpty && uf.isNotEmpty) '$localidade - $uf',
    ];
    return partes.join(', ');
  }
}

/// Cliente para a API gratuita ViaCEP, usada para preencher o endereço
/// automaticamente a partir do CEP informado no cadastro.
class ViaCepService {
  Future<EnderecoViaCep?> buscar(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;

    final uri = Uri.parse('https://viacep.com.br/ws/$digits/json/');
    final resposta = await http.get(uri);
    if (resposta.statusCode != 200) return null;

    final decodificado = jsonDecode(utf8.decode(resposta.bodyBytes));
    if (decodificado is! Map<String, dynamic> || decodificado['erro'] == true) {
      return null;
    }
    return EnderecoViaCep.fromJson(decodificado);
  }
}
