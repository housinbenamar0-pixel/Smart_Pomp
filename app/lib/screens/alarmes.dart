import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarme.dart';
import '../services/pompe_service.dart';

class AlarmesScreen extends StatelessWidget {
  const AlarmesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarmes et defauts')),
      body: StreamBuilder<Alarme>(
        stream: context.read<PompeService>().alarmeStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final alarme = snapshot.data!;
          if (!alarme.active) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 64),
                  SizedBox(height: 16),
                  Text('Aucune alarme active', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
          return Card(
            margin: const EdgeInsets.all(16),
            color: Colors.red.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    const Icon(Icons.warning_rounded, color: Colors.red, size: 32),
                    const SizedBox(width: 8),
                    Text(alarme.code,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                  ]),
                  const SizedBox(height: 12),
                  Text(alarme.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Cause : ${alarme.cause}',
                      style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Solution : ${alarme.solution}',
                      style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(alarme.timestamp,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
