class Project {
  final String projectId;
  final String userId;
  final String projectName;
  final String colour;
  final String? deadline;

  Project({
    required this.projectId,
    required this.userId,
    required this.projectName,
    required this.colour,
    this.deadline,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'],
      userId: json['userId'],
      projectName: json['projectName'],
      colour: json['colour'],
      deadline: json['deadline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'userId': userId,
      'projectName': projectName,
      'colour': colour,
      'deadline': deadline,
    };
  }
}
