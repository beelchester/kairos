import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/user.dart';
import 'models/session.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3333';

  static Future<void> addUser(User user) async {
    final url = Uri.parse('$baseUrl/add_user');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add user');
    }
  }

  static Future<void> addSession(String userId, Session session) async {
    final url = Uri.parse('$baseUrl/add_session/$userId');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(session.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add session');
    }
  }

  static Future<void> updateSession(String userId, Session session) async {
    final url = Uri.parse('$baseUrl/update_session/$userId');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(session.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update session');
    }
  }

  static Future<User?> getUser(String userId) async {
    final url = Uri.parse('$baseUrl/get_user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load user');
    }
  }

  static Future<Session?> checkActiveSession(String userId) async {
    final url = Uri.parse('$baseUrl/check_active_session/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to check active session');
    }
  }

  static Future<void> deleteUser(String userId) async {
    final url = Uri.parse('$baseUrl/delete_user/$userId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }
}