import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/pompe_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PompeService>().ecouterTout();
  }

  @override
  Widget build(BuildContext context) {
    final pompe = context.watch<PompeService>();
    final mesures = pompe.mesures;
    final alarme = pompe.alarme;
    final gps = pompe.gps;
    final bool enMarche = pompe.enMarche;
    final bool alarmeActive = alarme['active'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black87),
        title: const Text('Tableau de Bord',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
              onPressed: () {},
            ),
            if (alarmeActive)
              Positioned(right: 8, top: 8,
                child: Container(width: 12, height: 12,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                ),
              ),
          ]),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => context.read<PompeService>().ecouterTout(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // --- Bannière état pompe ---
            _banniereEtat(enMarche, alarmeActive, alarme),
            const SizedBox(height: 16),

            // --- 4 cartes mesures sortie ---
            GridView.count(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _carteMesure('Tension', _fmt(mesures['sortie_tension']), 'V', Icons.bolt, const Color(0xFFFFA726)),
                _carteMesure('Courant', _fmt(mesures['sortie_courant']), 'A', Icons.show_chart, const Color(0xFF26C6DA)),
                _carteMesure('Fréquence', _fmt(mesures['sortie_frequence']), 'Hz', Icons.waves, const Color(0xFF42A5F5)),
                _carteMesure('Puissance', _fmt(mesures['sortie_puissance']), 'kW', Icons.speed, const Color(0xFFEF5350)),
              ],
            ),
            const SizedBox(height: 16),

            // --- Entrée panneaux ---
            const Text('Entrée Panneaux Solaires',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _carteMesure('Tension DC', _fmt(mesures['tension_panneaux']), 'V', Icons.solar_power, const Color(0xFFFFA726))),
              const SizedBox(width: 12),
              Expanded(child: _carteMesure('Puissance', _fmt(mesures['entree_puissance']), 'kW', Icons.power, const Color(0xFF66BB6A))),
            ]),
            const SizedBox(height: 16),

            // --- GPS ---
            const Text('Localisation GPS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            _carteGPS(gps),
            const SizedBox(height: 12),

            // --- Opérateur SIM ---
            _carteOperateur(gps),
            const SizedBox(height: 8),

            // --- Timestamp ---
            if (mesures['timestamp'] != null)
              Center(child: Text('Mise à jour : ${mesures['timestamp']}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey))),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  String _fmt(dynamic val) {
    if (val == null) return '--';
    if (val is double) return val.toStringAsFixed(1);
    return val.toString();
  }

  Widget _banniereEtat(bool enMarche, bool alarmeActive, Map alarme) {
    final couleur = alarmeActive ? const Color(0xFFE53935) : enMarche ? const Color(0xFF1D9E75) : const Color(0xFF757575);
    final icone = alarmeActive ? Icons.warning_rounded : enMarche ? Icons.check_circle : Icons.stop_circle_outlined;
    final titre = alarmeActive ? (alarme['code'] ?? 'ALARME') : enMarche ? 'NORMAL' : 'ARRÊT';
    final sous = alarmeActive ? (alarme['description'] ?? 'Défaut détecté') : enMarche ? 'Fonctionnement normal de la pompe' : 'La pompe est à l\'arrêt';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('État de la Pompe', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
          const SizedBox(height: 4),
          Text(titre, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sous, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
        ])),
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icone, color: Colors.white, size: 30),
        ),
      ]),
    );
  }

  Widget _carteMesure(String titre, String valeur, String unite, IconData icone, Color couleur) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(icone, color: couleur, size: 20),
          const SizedBox(width: 6),
          Text(titre, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(valeur, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(width: 4),
          Padding(padding: const EdgeInsets.only(bottom: 2),
            child: Text(unite, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))),
        ]),
      ]),
    );
  }

  Widget _carteGPS(Map gps) {
    final lat = (gps['latitude'] ?? 0.0).toDouble();
    final lng = (gps['longitude'] ?? 0.0).toDouble();
    final valide = gps['valide'] ?? false;
    final lien = gps['google_maps'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(valide ? 'Latitude :  ${lat.toStringAsFixed(4)}° N' : 'GPS non disponible',
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
            if (valide) ...[
              const SizedBox(height: 4),
              Text('Longitude : ${lng.toStringAsFixed(4)}° E',
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
          ]),
          if (valide && lien.isNotEmpty)
            TextButton(
              onPressed: () => launchUrl(Uri.parse(lien), mode: LaunchMode.externalApplication),
              child: const Text('Voir sur la carte',
                  style: TextStyle(color: Color(0xFF1D9E75), fontWeight: FontWeight.w600)),
            ),
        ]),
        if (valide) ...[
          const SizedBox(height: 12),
          Container(
            height: 100, width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.location_on, color: Colors.red, size: 32),
              Text('${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _carteOperateur(Map gps) {
    final op = gps['operateur'] ?? 'Inconnu';
    final gprs = gps['gprs_connecte'] ?? false;
    Color couleur = Colors.grey;
    if (op.contains('Ooredoo')) couleur = const Color(0xFFE30613);
    else if (op.contains('Orange')) couleur = const Color(0xFFFF6600);
    else if (op.contains('Telecom')) couleur = const Color(0xFF003DA5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: couleur.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.sim_card, color: couleur, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(op, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(gprs ? 'GPRS connecté' : 'WiFi', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: gprs ? Colors.green.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(gprs ? 'GPRS' : 'WiFi',
              style: TextStyle(fontSize: 11, color: gprs ? Colors.green.shade700 : Colors.blue.shade700, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
