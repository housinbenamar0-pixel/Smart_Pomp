import 'package:flutter/material.dart';
import '../models/etat.dart';

class EtatPompeCard extends StatelessWidget {
  final EtatPompe etat;
  final VoidCallback onMarche;
  final VoidCallback onArret;
  final Function(double) onFrequenceChange;

  const EtatPompeCard({
    super.key,
    required this.etat,
    required this.onMarche,
    required this.onArret,
    required this.onFrequenceChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton.icon(
              onPressed: onMarche,
              icon: const Icon(Icons.play_arrow),
              label: const Text('MARCHE'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            ElevatedButton.icon(
              onPressed: onArret,
              icon: const Icon(Icons.stop),
              label: const Text('ARRET'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            const Text('Frequence consigne : '),
            Expanded(
              child: Slider(
                min: 0, max: 50, divisions: 100,
                value: etat.frequence,
                onChanged: onFrequenceChange,
              ),
            ),
            Text('${etat.frequence.toStringAsFixed(1)} Hz'),
          ]),
          if (etat.timerActif)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.timer, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Minuterie ${etat.timerMode} : ${etat.timerResteMinutes} min restantes'),
              ]),
            ),
          const SizedBox(height: 8),
          Text(
            'Etat : ${etat.enMarche ? "EN MARCHE" : "ARRET"}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ]),
      ),
    );
  }
}
