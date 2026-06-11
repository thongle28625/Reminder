import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  static const Duration _requestTimeout = Duration(seconds: 10);

  final String baseUrl;
  final http.Client _client;

  Future<dynamic> getJson(String path) async {
    try {
      final response = await _client
          .get(_uri(path), headers: _headers)
          .timeout(_requestTimeout);
      return _decodeResponse(response);
    } on TimeoutException {
      throw Exception(
        'Kết nối tới máy chủ bị quá thời gian chờ sau 10 giây. Hãy kiểm tra backend, IP và mạng.',
      );
    } on SocketException {
      throw Exception(
        'Không thể kết nối tới máy chủ. Hãy kiểm tra backend đang chạy, địa chỉ IP và mạng.',
      );
    } on http.ClientException {
      throw Exception('Yêu cầu tới máy chủ thất bại. Hãy thử lại.');
    }
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);

      return _decodeResponse(response);
    } on TimeoutException {
      throw Exception(
        'Kết nối tới máy chủ bị quá thời gian chờ sau 10 giây. Hãy kiểm tra backend, IP và mạng.',
      );
    } on SocketException {
      throw Exception(
        'Không thể kết nối tới máy chủ. Hãy kiểm tra backend đang chạy, địa chỉ IP và mạng.',
      );
    } on http.ClientException {
      throw Exception('Yêu cầu tới máy chủ thất bại. Hãy thử lại.');
    }
  }

  Future<dynamic> putJson(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .put(
            _uri(path),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);

      return _decodeResponse(response);
    } on TimeoutException {
      throw Exception(
        'Kết nối tới máy chủ bị quá thời gian chờ sau 10 giây. Hãy kiểm tra backend, IP và mạng.',
      );
    } on SocketException {
      throw Exception(
        'Không thể kết nối tới máy chủ. Hãy kiểm tra backend đang chạy, địa chỉ IP và mạng.',
      );
    } on http.ClientException {
      throw Exception('Yêu cầu tới máy chủ thất bại. Hãy thử lại.');
    }
  }

  Future<dynamic> deleteJson(String path) async {
    try {
      final response = await _client
          .delete(_uri(path), headers: _headers)
          .timeout(_requestTimeout);
      return _decodeResponse(response);
    } on TimeoutException {
      throw Exception(
        'Kết nối tới máy chủ bị quá thời gian chờ sau 10 giây. Hãy kiểm tra backend, IP và mạng.',
      );
    } on SocketException {
      throw Exception(
        'Không thể kết nối tới máy chủ. Hãy kiểm tra backend đang chạy, địa chỉ IP và mạng.',
      );
    } on http.ClientException {
      throw Exception('Yêu cầu tới máy chủ thất bại. Hãy thử lại.');
    }
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
      final apiMessage = _tryExtractApiMessage(response.body);
      if (apiMessage != null && apiMessage.isNotEmpty) {
        throw Exception(apiMessage);
      }

      throw Exception('API ${response.statusCode}: ${response.body}');
    }

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  String? _tryExtractApiMessage(String body) {
    if (body.isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String) {
          return message;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
