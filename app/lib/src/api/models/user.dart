import 'package:uuid/uuid.dart';

class User {
  final Uuid userId;
  final String name;
  final String email;
  final int totalTime;
  final Duration createdAt;
  final Duration updatedAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.totalTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      totalTime: json['totalTime'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'totalTime': totalTime,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
