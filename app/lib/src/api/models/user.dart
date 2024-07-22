import 'package:kairos/src/api/models/session.dart';

class User {
  final String userId;
  final String name;
  final String email;
  final List<Session>? sessions;

  User({
    required this.userId,
    required this.name,
    required this.email,
    this.sessions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      sessions: (json['sessions'] as List<dynamic>?)
          ?.map((item) => Session.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'sessions': sessions,
    };
  }
}
