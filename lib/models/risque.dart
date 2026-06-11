enum NiveauRisque { faible, moyen, eleve }

class Risque {
  final String metrique;
  final String label;
  final double valeurActuelle;
  final double valeurPredite1h;
  final double seuil;
  final NiveauRisque niveau;
  final double pente; // unité/heure — positif = montée
  final String? minutesAvantAlerte; // null si pas de croisement prévu

  const Risque({
    required this.metrique,
    required this.label,
    required this.valeurActuelle,
    required this.valeurPredite1h,
    required this.seuil,
    required this.niveau,
    required this.pente,
    this.minutesAvantAlerte,
  });

  String get tendanceLabel {
    if (pente.abs() < 0.05) return 'Stable';
    return pente > 0 ? 'En hausse' : 'En baisse';
  }
}
