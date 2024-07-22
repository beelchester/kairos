class Session {
  final String sessionId;
  final String startedAt;
  final String? endedAt;
  final String? duration;

  Session({
    required this.sessionId,
    required this.startedAt,
    this.endedAt,
    this.duration,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'],
      startedAt: json['startedAt'],
      endedAt: json['endedAt'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'duration': duration,
    };
  }
}
