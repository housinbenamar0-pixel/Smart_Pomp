import 'package:flutter/material.dart';
import '../models/mesure.dart';

class MesuresCard extends StatelessWidget {
  final Mesure mesure;
  const MesuresCard({super.key, required this.mesure});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _buildRow('Tension panneaux', '${mesure.tensionPanneaux.toStringAsFixed(1)} V'),
          _buildRow('Courant sortie',   '${mesure.sortieCourant.toStringAsFixed(2)} A'),
          _buildRow('Puissance sortie', '${mesure.sortiePuissance.toStringAsFixed(2)} kW'),
          _buildRow('Frequence sortie', '${mesure.sortieFrequence.toStringAsFixed(1)} Hz'),
          _buildRow('Tension sortie',   '${mesure.sortieTension.toStringAsFixed(0)} V'),
          const Divider(),
          Text('Derniere mise a jour : ${mesure.timestamp}',
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ]),
    );
  }
}
