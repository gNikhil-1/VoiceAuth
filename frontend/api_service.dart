

import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5001';


  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );


    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? data['error'] ?? 'Login failed',
    };
  }


  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'email': email,
        'password': password,
      }),
    );


    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 201,
      'message': data['message'] ?? data['error'] ?? 'Registration failed',
    };
  }


  static Future<List<Map<String, dynamic>>> fetchList(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load data from $endpoint');
  }
}
