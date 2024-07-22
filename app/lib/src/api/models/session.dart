class Session {
  final String sessionId;
  final String startedAt;
  final String? endedAt;

  Session({
    required this.sessionId,
    required this.startedAt,
    this.endedAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'],
      startedAt: json['startedAt'],
      endedAt: json['endedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startedAt': startedAt,
      'endedAt': endedAt,
    };
  }
}
