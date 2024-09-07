import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kairos/src/utils.dart';
import 'package:uuid/uuid.dart';
import 'models/user.dart';
import 'models/session.dart';

class ApiService {
  //WARN: dont push
  static const String baseUrl = 'http://localhost:3333';

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

  static Future<void> addSession(Uuid userId, Session session) async {
    final url = Uri.parse('$baseUrl/add_session');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(session.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add session');
    }
  }

  static Future<void> updateSession(Uuid userId, Session session) async {
    final url = Uri.parse('$baseUrl/update_session');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(session.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update session');
    }
  }

  static Future<User?> getUser(Uuid userId) async {
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

  static Future<List<Session>> getSessions(Uuid userId) async {
    final url = Uri.parse('$baseUrl/get_sessions/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((e) => Session.fromJson(e))
          .toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  static Future<bool> checkHealth() async {
    final url = Uri.parse('$baseUrl/health_check');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<Session?> checkOnlineActiveSession(Uuid userId) async {
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

  static Future<void> deleteUser(Uuid userId) async {
    final url = Uri.parse('$baseUrl/delete_user/$userId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  static Future<String> getTodaysFocusTime(Uuid userId) async {
    final url = Uri.parse('$baseUrl/get_todays_focus_time/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var duration = (jsonDecode(response.body) as int);
      return formatSeconds(duration);
    } else if (response.statusCode == 404) {
      return formatSeconds(0);
    } else {
      throw Exception('Failed to get todays sessions');
    }
  }
}
