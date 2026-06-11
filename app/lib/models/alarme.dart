class Alarme {
  final bool active;
  final String code;
  final String description;
  final String cause;
  final String solution;
  final String timestamp;

  Alarme({
    required this.active,
    required this.code,
    required this.description,
    required this.cause,
    required this.solution,
    required this.timestamp,
  });

  factory Alarme.fromJson(Map<String, dynamic> json) {
    return Alarme(
      active: json['active'] ?? false,
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      cause: json['cause'] ?? '',
      solution: json['solution'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}