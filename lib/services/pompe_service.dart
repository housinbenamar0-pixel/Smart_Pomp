import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class PompeService extends ChangeNotifier {
  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://solarpumpsupervision-b0c86-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  Map<String, dynamic> mesures = {};
  Map<String, dynamic> etat    = {};
  Map<String, dynamic> alarme  = {};
  Map<String, dynamic> gps     = {};

  bool   get enMarche         => etat['en_marche'] ?? false;
  double get frequence        => (etat['frequence'] ?? 0.0).toDouble();
  String? get alarmeCode      => alarme['active'] == true ? alarme['code']        : null;
  String? get alarmeDescription => alarme['active'] == true ? alarme['description'] : null;

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
      notifyListeners();
    });
    _db.child('pompe/gps').onValue.listen((e) {
      gps = Map<String, dynamic>.from(e.snapshot.value as Map? ?? {});
      notifyListeners();
    });
  }

  Future<void> envoyerCommande(String ordre, {Map<String, dynamic>? extras}) async {
    await _db.child('pompe/commande').set({
      'ordre': ordre,
      'statut': 'EN_ATTENTE',
      'timestamp': DateTime.now().toIso8601String(),
      ...?extras,
    });
  }

  Future<void> demarrer()           => envoyerCommande('START');
  Future<void> arreter()            => envoyerCommande('STOP');
  Future<void> setFrequence(double f) => envoyerCommande('SET_FREQ', extras: {'frequence': f});
  Future<void> resetVariateur()     => envoyerCommande('RESET_VARIATEUR');
}
