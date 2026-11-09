import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

const apiBaseOverride = String.fromEnvironment('API_BASE');
final apiBase = apiBaseOverride.isNotEmpty
    ? apiBaseOverride
    : kIsWeb
        ? 'http://127.0.0.1:8000/api/v1'
        : 'http://10.0.2.2:8000/api/v1';

class Api {
  String? token;

  Future<dynamic> call(String path,
      {String method = 'GET',
      Map<String, dynamic>? data,
      bool auth = true}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (auth && token != null) 'Authorization': 'Bearer $token'
    };
    final uri = Uri.parse('$apiBase/$path');
    final response = await (method == 'POST'
            ? http.post(uri, headers: headers, body: jsonEncode(data))
            : method == 'PATCH'
                ? http.patch(uri, headers: headers, body: jsonEncode(data))
                : http.get(uri, headers: headers))
        .timeout(const Duration(seconds: 20));
    final body = response.body.isEmpty ? {} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body is Map
          ? (body['message'] ?? 'Request failed (${response.statusCode})')
          : 'Request failed');
    }
    return body;
  }
}

final api = Api();
