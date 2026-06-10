import 'package:firebase_database/firebase_database.dart';
import '../models/mesure.dart';
import '../models/etat.dart';
import '../models/alarme.dart';
import '../models/gps_data.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Stream<Mesure> get mesuresStream {
    return _db.child('pompe/mesures').onValue.map((event) {
      final Map<String, dynamic> map =
      Map<String, dynamic>.from(event.snapshot.value as Map);
      return Mesure.fromJson(map);
    });
  }

  Stream<EtatPompe> get etatStream {
    return _db.child('pompe/etat').onValue.map((event) {
      final Map<String, dynamic> map =
      Map<String, dynamic>.from(event.snapshot.value as Map);
      return EtatPompe.fromJson(map);
    });
  }

  Stream<Alarme> get alarmeStream {
    return _db.child('pompe/alarme').onValue.map((event) {
      final Map<String, dynamic> map =
      Map<String, dynamic>.from(event.snapshot.value as Map);
      return Alarme.fromJson(map);
    });
  }

  Stream<GPSData> get gpsStream {
    return _db.child('pompe/gps').onValue.map((event) {
      final Map<String, dynamic> map =
      Map<String, dynamic>.from(event.snapshot.value as Map);
      return GPSData.fromJson(map);
    });
  }

  Future<void> _sendCommand(Map<String, dynamic> command) async {
    await _db.child('pompe/commande').set({
      ...command,
      'statut': 'EN_ATTENTE',
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> demarrerPompe() async => _sendCommand({'ordre': 'START'});
  Future<void> arreterPompe() async => _sendCommand({'ordre': 'STOP'});
  Future<void> setFrequence(double freq) async =>
      _sendCommand({'ordre': 'SET_FREQ', 'frequence': freq});
  Future<void> resetVariateur() async =>
      _sendCommand({'ordre': 'RESET_VARIATEUR'});

  Future<void> startTimerRun(int heures, int minutes) async => _sendCommand({
    'ordre': 'TIMER_RUN',
    'timer_heures': heures,
    'timer_minutes': minutes,
  });
  Future<void> startTimerStop(int heures, int minutes) async => _sendCommand({
    'ordre': 'TIMER_STOP',
    'timer_heures': heures,
    'timer_minutes': minutes,
  });
  Future<void> annulerTimer() async => _sendCommand({'ordre': 'TIMER_OFF'});

  Future<void> setParametre(String param, int valeur) async => _sendCommand({
    'ordre': 'SET_PARAM',
    'parametre': param,
    'valeur': valeur,
  });

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