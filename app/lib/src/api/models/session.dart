import 'package:uuid/uuid.dart';

class Session {
  final Uuid sessionId;
  final Uuid userId;
  final String startedAt;
  String? endedAt;
  String? duration;

  Session({
    required this.sessionId,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.duration,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'],
      userId: json['userId'],
      startedAt: json['startedAt'],
      endedAt: json['endedAt'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'duration': duration,
    };
  }
}
