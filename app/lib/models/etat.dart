class EtatPompe {
  final bool enMarche;
  final double frequence;
  final bool timerActif;
  final int timerResteMinutes;
  final String timerMode;
  final String timestamp;

  EtatPompe({
    required this.enMarche,
    required this.frequence,
    required this.timerActif,
    required this.timerResteMinutes,
    required this.timerMode,
    required this.timestamp,
  });

  factory EtatPompe.fromJson(Map<String, dynamic> json) {
    return EtatPompe(
      enMarche: json['en_marche'] ?? false,
      frequence: (json['frequence'] ?? 0).toDouble(),
      timerActif: json['timer_actif'] ?? false,
      timerResteMinutes: json['timer_reste_minutes'] ?? 0,
      timerMode: json['timer_mode'] ?? 'NONE',
      timestamp: json['timestamp'] ?? '',
    );
  }
}