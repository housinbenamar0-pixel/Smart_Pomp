class Mesure {
  final double tensionPanneaux;
  final double tensionBusDc;
  final double sortieTension;
  final double sortieCourant;
  final double sortieFrequence;
  final double sortiePuissance;
  final double entreeCourant;
  final double entreePuissance;
  final String timestamp;

  Mesure({
    required this.tensionPanneaux,
    required this.tensionBusDc,
    required this.sortieTension,
    required this.sortieCourant,
    required this.sortieFrequence,
    required this.sortiePuissance,
    required this.entreeCourant,
    required this.entreePuissance,
    required this.timestamp,
  });

  factory Mesure.fromJson(Map<String, dynamic> json) {
    return Mesure(
      tensionPanneaux: (json['tension_panneaux'] ?? 0).toDouble(),
      tensionBusDc: (json['tension_bus_dc'] ?? 0).toDouble(),
      sortieTension: (json['sortie_tension'] ?? 0).toDouble(),
      sortieCourant: (json['sortie_courant'] ?? 0).toDouble(),
      sortieFrequence: (json['sortie_frequence'] ?? 0).toDouble(),
      sortiePuissance: (json['sortie_puissance'] ?? 0).toDouble(),
      entreeCourant: (json['entree_courant'] ?? 0).toDouble(),
      entreePuissance: (json['entree_puissance'] ?? 0).toDouble(),
      timestamp: json['timestamp'] ?? '',
    );
  }
}