import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<dynamic> getJson(String path) async {
    final response = await _client.get(_uri(path), headers: _headers);
    return _decodeResponse(response);
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  Future<dynamic> putJson(String path, Map<String, dynamic> body) async {
    final response = await _client.put(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  Future<dynamic> deleteJson(String path) async {
    final response = await _client.delete(_uri(path), headers: _headers);
    return _decodeResponse(response);
  }

  Uri _uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized');
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }
}
