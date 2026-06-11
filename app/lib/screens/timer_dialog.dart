import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pompe_service.dart';

void showTimerDialog(BuildContext context) {
  int heures = 0;
  int minutes = 0;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Minuterie'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              const Text('Heures : '),
              Expanded(
                child: Slider(
                  min: 0, max: 23, divisions: 23,
                  value: heures.toDouble(),
                  onChanged: (val) => setState(() => heures = val.toInt()),
                ),
              ),
              Text('$heures h'),
            ]),
            Row(children: [
              const Text('Minutes : '),
              Expanded(
                child: Slider(
                  min: 0, max: 59, divisions: 59,
                  value: minutes.toDouble(),
                  onChanged: (val) => setState(() => minutes = val.toInt()),
                ),
              ),
              Text('$minutes min'),
            ]),
          ]),
          actions: [
            TextButton(
              onPressed: () {
                context.read<PompeService>().startTimerRun(heures, minutes);
                Navigator.pop(ctx);
              },
              child: const Text('MARCHE puis arret'),
            ),
            TextButton(
              onPressed: () {
                context.read<PompeService>().startTimerStop(heures, minutes);
                Navigator.pop(ctx);
              },
              child: const Text('ARRET temporaire'),
            ),
            TextButton(
              onPressed: () {
                context.read<PompeService>().annulerTimer();
                Navigator.pop(ctx);
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      });
    },
  );
}
