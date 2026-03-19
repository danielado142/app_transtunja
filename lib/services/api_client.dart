import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://tu-api.com/api';

  final http.Client _httpClient;

  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Map<String, String> _buildHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _buildUri(String endpoint) {
    return Uri.parse('$baseUrl$endpoint');
  }

  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final response = await _httpClient.get(
      _buildUri(endpoint),
      headers: _buildHeaders(token: token),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await _httpClient.post(
      _buildUri(endpoint),
      headers: _buildHeaders(token: token),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await _httpClient.put(
      _buildUri(endpoint),
      headers: _buildHeaders(token: token),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    final response = await _httpClient.delete(
      _buildUri(endpoint),
      headers: _buildHeaders(token: token),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final dynamic decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      }

      return {'data': decodedBody};
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  void dispose() {
    _httpClient.close();
  }
}
