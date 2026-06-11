import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/alarme.dart';
import '../models/etat.dart';
import '../models/gps_data.dart';
import '../models/mesure.dart';
import '../utils/notifications.dart';

class PompeService extends ChangeNotifier {
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://solarpumpsupervision-b0c86-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  // --- État brut pour le dashboard (Provider) ---
  Map<String, dynamic> mesures = {};
  Map<String, dynamic> etat    = {};
  Map<String, dynamic> alarme  = {};
  Map<String, dynamic> gps     = {};

  bool   get enMarche  => etat['en_marche'] ?? false;
  double get frequence => (etat['frequence'] ?? 0.0).toDouble();

  bool _alarmeWasActive = false;

  void ecouterTout() {
    _db.child('pompe/mesures').onValue.listen((e) {
      mesures = Map<String, dynamic>.from(e.snapshot.value as Map? ?? {});
      notifyListeners();
    });
    _db.child('pompe/etat').onValue.listen((e) {
      etat = Map<String, dynamic>.from(e.snapshot.value as Map? ?? {});
      notifyListeners();
    });
    _db.child('pompe/alarme').onValue.listen((e) {
      alarme = Map<String, dynamic>.from(e.snapshot.value as Map? ?? {});
      _verifierAlarme();
      notifyListeners();
    });
    _db.child('pompe/gps').onValue.listen((e) {
      gps = Map<String, dynamic>.from(e.snapshot.value as Map? ?? {});
      notifyListeners();
    });
  }

  void _verifierAlarme() {
    final active = alarme['active'] == true;
    if (active && !_alarmeWasActive) {
      final code = alarme['code'] ?? 'Alarme';
      final desc = alarme['description'] ?? 'Défaut détecté sur la pompe';
      showAlarmNotification(code, desc);
    }
    _alarmeWasActive = active;
  }

  // --- Streams typés pour les autres écrans ---
  Stream<Alarme> get alarmeStream => _db.child('pompe/alarme').onValue.map(
        (e) => Alarme.fromJson(
            Map<String, dynamic>.from(e.snapshot.value as Map? ?? {})),
      );

  Stream<GPSData> get gpsStream => _db.child('pompe/gps').onValue.map(
        (e) => GPSData.fromJson(
            Map<String, dynamic>.from(e.snapshot.value as Map? ?? {})),
      );

  Stream<Mesure> get mesuresStream => _db.child('pompe/mesures').onValue.map(
        (e) => Mesure.fromJson(
            Map<String, dynamic>.from(e.snapshot.value as Map? ?? {})),
      );

  Stream<EtatPompe> get etatStream => _db.child('pompe/etat').onValue.map(
        (e) => EtatPompe.fromJson(
            Map<String, dynamic>.from(e.snapshot.value as Map? ?? {})),
      );

  // --- Commandes ---
  Future<void> _envoyerCommande(Map<String, dynamic> commande) async {
    await _db.child('pompe/commande').set({
      ...commande,
      'statut': 'EN_ATTENTE',
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> demarrer()              => _envoyerCommande({'ordre': 'START'});
  Future<void> arreter()               => _envoyerCommande({'ordre': 'STOP'});
  Future<void> setFrequence(double f)  => _envoyerCommande({'ordre': 'SET_FREQ', 'frequence': f});
  Future<void> resetVariateur()        => _envoyerCommande({'ordre': 'RESET_VARIATEUR'});

  Future<void> startTimerRun(int heures, int minutes) => _envoyerCommande({
        'ordre': 'TIMER_RUN',
        'timer_heures': heures,
        'timer_minutes': minutes,
      });

  Future<void> startTimerStop(int heures, int minutes) => _envoyerCommande({
        'ordre': 'TIMER_STOP',
        'timer_heures': heures,
        'timer_minutes': minutes,
      });

  Future<void> annulerTimer() => _envoyerCommande({'ordre': 'TIMER_OFF'});

  Future<void> setParametre(String param, int valeur) => _envoyerCommande({
        'ordre': 'SET_PARAM',
        'parametre': param,
        'valeur': valeur,
      });

  // --- Lectures ponctuelles ---
  Future<Map<String, dynamic>> getSeuils() async {
    final snapshot = await _db.child('pompe/seuils').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {};
  }

  Future<Map<String, dynamic>> getHistoriqueJour(String date) async {
    final snapshot = await _db.child('historique/$date').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {};
  }
}
