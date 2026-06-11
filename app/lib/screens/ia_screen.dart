import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/risque.dart';
import '../services/pompe_service.dart';
import '../services/prediction_service.dart';

class IAScreen extends StatefulWidget {
  const IAScreen({super.key});

  @override
  State<IAScreen> createState() => _IAScreenState();
}

class _IAScreenState extends State<IAScreen> {
  List<Risque> _risques = [];
  Map<String, dynamic> _historique = {};
  bool _loading = true;
  String _erreur = '';

  @override
  void initState() {
    super.initState();
    _analyser();
  }

  Future<void> _analyser() async {
    setState(() { _loading = true; _erreur = ''; });
    try {
      final pompe  = context.read<PompeService>();
      final date   = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final histo  = await pompe.getHistoriqueJour(date);
      final seuils = await pompe.getSeuils();

      final courant   = (pompe.mesures['sortie_courant']  ?? 0).toDouble();
      final puissance = (pompe.mesures['sortie_puissance'] ?? 0).toDouble();

      final risques = PredictionService.analyser(
        historique:        histo,
        seuils:            seuils,
        dernierCourant:    courant,
        dernierePuissance: puissance,
      );

      setState(() {
        _historique = histo;
        _risques    = risques;
        _loading    = false;
      });
    } catch (e) {
      setState(() { _erreur = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Diagnostic IA',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _analyser,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _erreur.isNotEmpty
              ? Center(child: Text(_erreur))
              : RefreshIndicator(
                  onRefresh: _analyser,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _enTete(),
                      const SizedBox(height: 16),
                      if (_risques.isEmpty)
                        _carteAucunRisque()
                      else ...[
                        ..._risques.map(_carteRisque),
                        const SizedBox(height: 16),
                      ],
                      if (_historique.isNotEmpty) ...[
                        _titreSection('Tendance courant (A)'),
                        const SizedBox(height: 8),
                        _graphiqueTendance('courant_sortie', Colors.blue),
                        const SizedBox(height: 16),
                        _titreSection('Tendance puissance (kW)'),
                        const SizedBox(height: 8),
                        _graphiqueTendance('puissance_sortie', Colors.orange),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _enTete() {
    final niveauGlobal = _risques.isEmpty
        ? NiveauRisque.faible
        : _risques.first.niveau;
    final couleur = _couleurNiveau(niveauGlobal);
    final icone   = _iconeNiveau(niveauGlobal);
    final texte   = _texteNiveauGlobal(niveauGlobal);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Analyse prédictive', style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
            const SizedBox(height: 4),
            Text(texte, style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Basée sur l\'historique du jour',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
          ]),
        ),
        Icon(icone, color: Colors.white, size: 40),
      ]),
    );
  }

  Widget _carteAucunRisque() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 12),
          const Text('Aucune anomalie détectée',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Les paramètres sont dans les limites normales',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _carteRisque(Risque r) {
    final couleur = _couleurNiveau(r.niveau);
    final bg      = couleur.withValues(alpha: 0.08);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: couleur, width: 4)),
          borderRadius: BorderRadius.circular(12),
          color: bg,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(_iconeNiveau(r.niveau), color: couleur, size: 20),
            const SizedBox(width: 8),
            Text(r.label,
                style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 15, color: couleur)),
            const Spacer(),
            _badgeNiveau(r.niveau),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _indicateur('Actuel',   '${r.valeurActuelle.toStringAsFixed(1)} A'),
            const SizedBox(width: 16),
            _indicateur('Prédiction +1h', '${r.valeurPredite1h.toStringAsFixed(1)} A'),
            const SizedBox(width: 16),
            _indicateur('Seuil', '${r.seuil.toStringAsFixed(0)} A'),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(
              r.pente > 0.05 ? Icons.trending_up :
              r.pente < -0.05 ? Icons.trending_down : Icons.trending_flat,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(r.tendanceLabel,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            if (r.minutesAvantAlerte != null) ...[
              const SizedBox(width: 12),
              Icon(Icons.alarm, size: 14, color: couleur),
              const SizedBox(width: 4),
              Text('Alerte potentielle dans ${r.minutesAvantAlerte}',
                  style: TextStyle(fontSize: 12, color: couleur,
                      fontWeight: FontWeight.w600)),
            ],
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (r.valeurActuelle / r.seuil).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: couleur,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${((r.valeurActuelle / r.seuil) * 100).toStringAsFixed(0)}% du seuil',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ]),
      ),
    );
  }

  Widget _indicateur(String label, String valeur) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      Text(valeur, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _badgeNiveau(NiveauRisque n) {
    final label  = n == NiveauRisque.eleve ? 'ÉLEVÉ' :
                   n == NiveauRisque.moyen ? 'MOYEN' : 'FAIBLE';
    final couleur = _couleurNiveau(n);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleur.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, color: couleur)),
    );
  }

  Widget _titreSection(String titre) {
    return Text(titre,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
            color: Colors.black87));
  }

  Widget _graphiqueTendance(String key, Color couleur) {
    final heures = _historique.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    final spots = <FlSpot>[];
    for (final h in heures) {
      final v = _historique[h];
      if (v is Map) {
        spots.add(FlSpot(
          int.parse(h).toDouble(),
          (v[key] ?? 0).toDouble(),
        ));
      }
    }

    if (spots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text('Pas de données',
              style: TextStyle(color: Colors.grey.shade500))),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: couleur,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: couleur.withValues(alpha: 0.1),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 4,
                    getTitlesWidget: (v, _) =>
                        Text('${v.toInt()}h', style: const TextStyle(fontSize: 10)),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) =>
                        Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
                  ),
                ),
                topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Color _couleurNiveau(NiveauRisque n) {
    switch (n) {
      case NiveauRisque.eleve:  return const Color(0xFFE53935);
      case NiveauRisque.moyen:  return const Color(0xFFFF8F00);
      case NiveauRisque.faible: return const Color(0xFF1D9E75);
    }
  }

  IconData _iconeNiveau(NiveauRisque n) {
    switch (n) {
      case NiveauRisque.eleve:  return Icons.warning_rounded;
      case NiveauRisque.moyen:  return Icons.error_outline;
      case NiveauRisque.faible: return Icons.check_circle_outline;
    }
  }

  String _texteNiveauGlobal(NiveauRisque n) {
    switch (n) {
      case NiveauRisque.eleve:  return 'Risque élevé détecté';
      case NiveauRisque.moyen:  return 'Risque modéré';
      case NiveauRisque.faible: return 'Système normal';
    }
  }
}
