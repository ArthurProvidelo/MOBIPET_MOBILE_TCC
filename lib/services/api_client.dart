import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'token_storage.dart';

/// Erro lançado quando a API Laravel responde com status de erro (4xx/5xx).
/// [errors] carrega os erros de validação por campo, quando houver.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, List<String>> errors;

  ApiException({required this.statusCode, required this.message, this.errors = const {}});

  @override
  String toString() => message;
}

/// Base URL da API Laravel.
///
/// O servidor PHP está rodando com `-S 192.168.0.113:8080`, ou seja,
/// só aceita conexões nesse IP da rede local (não em localhost/10.0.2.2).
/// Isso funciona tanto para emulador quanto para dispositivo físico na
/// mesma rede Wi-Fi. Se reiniciar o servidor em outro host/porta, atualize
/// a constante abaixo.
class ApiConfig {
  static const String _hostLaravel = '192.168.0.113:8080';

  static String get baseUrl => 'http://$_hostLaravel/api';
}

/// Cliente HTTP fino para a API do sistema web (Laravel). Injeta o token
/// Sanctum salvo em [TokenStorage] e traduz respostas de erro em
/// [ApiException].
class ApiClient {
  Future<dynamic> get(String path) => _enviar('GET', path);

  Future<dynamic> post(String path, [Map<String, dynamic>? corpo]) => _enviar('POST', path, corpo);

  Future<dynamic> put(String path, [Map<String, dynamic>? corpo]) => _enviar('PUT', path, corpo);

  Future<dynamic> patch(String path, [Map<String, dynamic>? corpo]) => _enviar('PATCH', path, corpo);

  Future<dynamic> delete(String path) => _enviar('DELETE', path);

  Future<dynamic> _enviar(String metodo, String path, [Map<String, dynamic>? corpo]) async {
    final token = await TokenStorage.ler();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = corpo != null ? jsonEncode(corpo) : null;

    late final http.Response resposta;
    try {
      switch (metodo) {
        case 'GET':
          resposta = await http.get(uri, headers: headers);
          break;
        case 'POST':
          resposta = await http.post(uri, headers: headers, body: body);
          break;
        case 'PUT':
          resposta = await http.put(uri, headers: headers, body: body);
          break;
        case 'PATCH':
          resposta = await http.patch(uri, headers: headers, body: body);
          break;
        case 'DELETE':
          resposta = await http.delete(uri, headers: headers);
          break;
        default:
          throw ArgumentError('Método HTTP não suportado: $metodo');
      }
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'Não foi possível conectar ao servidor. Verifique sua conexão.');
    }

    if (resposta.statusCode == 204 || resposta.body.isEmpty) {
      return null;
    }

    final decodificado = jsonDecode(utf8.decode(resposta.bodyBytes));

    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return decodificado;
    }

    final mapa = decodificado is Map<String, dynamic> ? decodificado : <String, dynamic>{};
    final errosBrutos = mapa['errors'];
    final erros = <String, List<String>>{};
    if (errosBrutos is Map) {
      errosBrutos.forEach((chave, valor) {
        erros[chave.toString()] = (valor as List).map((e) => e.toString()).toList();
      });
    }

    throw ApiException(
      statusCode: resposta.statusCode,
      message: (mapa['message'] as String?) ?? 'Ocorreu um erro inesperado.',
      errors: erros,
    );
  }
}
