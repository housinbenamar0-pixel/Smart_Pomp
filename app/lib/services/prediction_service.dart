import '../models/risque.dart';

class PredictionService {
  // Régression linéaire simple : y = slope * x + intercept
  // Retourne (slope, intercept)
  static (double, double) _regressionLineaire(List<double> y) {
    final n = y.length;
    if (n < 2) return (0, y.isEmpty ? 0 : y.last);

    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      sumX  += i;
      sumY  += y[i];
      sumXY += i * y[i];
      sumX2 += i * i.toDouble();
    }
    final denom = n * sumX2 - sumX * sumX;
    if (denom == 0) return (0, sumY / n);
    final slope     = (n * sumXY - sumX * sumY) / denom;
    final intercept = (sumY - slope * sumX) / n;
    return (slope, intercept);
  }

  // Prédit la valeur à (n + horizonHeures) heures depuis le dernier point
  static double _predire(List<double> y, double horizonHeures) {
    final (slope, intercept) = _regressionLineaire(y);
    return intercept + slope * (y.length - 1 + horizonHeures);
  }

  // Calcule dans combien de minutes la tendance atteint le seuil
  // Retourne null si jamais ou déjà dépassé
  static String? _minutesAvantCroisement(
      List<double> y, double seuil, bool montee) {
    final (slope, intercept) = _regressionLineaire(y);
    if ((montee && slope <= 0) || (!montee && slope >= 0)) return null;
    // slope en unité/heure, résoudre : intercept + slope * x = seuil
    final xCroisement = (seuil - intercept) / slope;
    final deltaHeures = xCroisement - (y.length - 1);
    if (deltaHeures <= 0 || deltaHeures > 12) return null;
    final minutes = (deltaHeures * 60).round();
    return '~$minutes min';
  }

  static NiveauRisque _calculerNiveau(
      double valeur, double predite1h, double seuil, bool montee) {
    if (seuil <= 0) return NiveauRisque.faible;
    final ratioActuel  = montee ? valeur / seuil : 1 - valeur / seuil;
    final ratioPredite = montee ? predite1h / seuil : 1 - predite1h / seuil;
    if (ratioActuel >= 0.90 || ratioPredite >= 0.95) return NiveauRisque.eleve;
    if (ratioActuel >= 0.70 || ratioPredite >= 0.80) return NiveauRisque.moyen;
    return NiveauRisque.faible;
  }

  /// Analyse l'historique et retourne la liste des risques détectés.
  ///
  /// [historique] : Map{heure → {courant_sortie, puissance_sortie, ...}}
  /// [seuils]     : Map depuis pompe/seuils
  /// [dernierCourant] : valeur temps réel du courant sortie
  /// [dernierePuissance] : valeur temps réel de la puissance sortie
  static List<Risque> analyser({
    required Map<String, dynamic> historique,
    required Map<String, dynamic> seuils,
    required double dernierCourant,
    required double dernierePuissance,
  }) {
    // Extraire les séries chronologiques (triées par heure)
    final heures = historique.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    final courants   = <double>[];
    final puissances = <double>[];

    for (final h in heures) {
      final v = historique[h];
      if (v is Map) {
        courants.add((v['courant_sortie']   ?? 0).toDouble());
        puissances.add((v['puissance_sortie'] ?? 0).toDouble());
      }
    }

    // Ajouter la valeur temps réel comme dernier point
    if (dernierCourant > 0)   courants.add(dernierCourant);
    if (dernierePuissance > 0) puissances.add(dernierePuissance);

    final risques = <Risque>[];

    // --- Risque surintensité (courant trop élevé) ---
    final seuilSurint = (seuils['surintensite'] ?? 0).toDouble();
    if (courants.length >= 2 && seuilSurint > 0) {
      final (slope, _) = _regressionLineaire(courants);
      final predite1h  = _predire(courants, 1.0);
      final niveau     = _calculerNiveau(
          courants.last, predite1h, seuilSurint, true);
      final eta = _minutesAvantCroisement(courants, seuilSurint, true);
      risques.add(Risque(
        metrique:         'courant',
        label:            'Surintensité',
        valeurActuelle:   courants.last,
        valeurPredite1h:  predite1h,
        seuil:            seuilSurint,
        niveau:           niveau,
        pente:            slope,
        minutesAvantAlerte: eta,
      ));
    }

    // --- Risque marche à sec (courant trop faible en marche) ---
    final seuilMarcheSec = (seuils['marche_sec'] ?? 0).toDouble();
    if (courants.length >= 2 && seuilMarcheSec > 0) {
      final (slope, _) = _regressionLineaire(courants);
      final predite1h  = _predire(courants, 1.0);
      final niveau     = _calculerNiveau(
          courants.last, predite1h, seuilMarcheSec, false);
      final eta = _minutesAvantCroisement(courants, seuilMarcheSec, false);
      risques.add(Risque(
        metrique:           'marche_sec',
        label:              'Marche à sec',
        valeurActuelle:     courants.last,
        valeurPredite1h:    predite1h,
        seuil:              seuilMarcheSec,
        niveau:             niveau,
        pente:              slope,
        minutesAvantAlerte: eta,
      ));
    }

    // --- Risque puissance minimale ---
    final seuilPuissMin = (seuils['puiss_min'] ?? 0).toDouble();
    if (puissances.length >= 2 && seuilPuissMin > 0) {
      final (slope, _) = _regressionLineaire(puissances);
      final predite1h  = _predire(puissances, 1.0);
      final niveau     = _calculerNiveau(
          puissances.last, predite1h, seuilPuissMin, false);
      final eta = _minutesAvantCroisement(puissances, seuilPuissMin, false);
      risques.add(Risque(
        metrique:           'puissance',
        label:              'Puissance minimale',
        valeurActuelle:     puissances.last,
        valeurPredite1h:    predite1h,
        seuil:              seuilPuissMin,
        niveau:             niveau,
        pente:              slope,
        minutesAvantAlerte: eta,
      ));
    }

    // Trier : risques élevés en premier
    risques.sort((a, b) => b.niveau.index.compareTo(a.niveau.index));
    return risques;
  }
}
