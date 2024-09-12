class Settings {
  final int maxSessionDuration;

  Settings({
    required this.maxSessionDuration,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      maxSessionDuration: json['maxSessionDuration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxSessionDuration': maxSessionDuration,
    };
  }
}
