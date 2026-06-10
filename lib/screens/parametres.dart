import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});
  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final firebase = FirebaseService();
  Map<String, dynamic> seuils = {};
  bool loading = true;

  final List<ParamDef> parametres = [
    ParamDef('F14.11', 'Seuil veille (V)', 0, 1000),
    ParamDef('F14.12', 'Seuil reveil (V)', 0, 1000),
    ParamDef('F14.14', 'Frequence min (Hz)', 0, 300),
    ParamDef('F14.17', 'Courant marche a sec (A)', 0, 100),
    ParamDef('F14.20', 'Seuil surintensite (A)', 0, 100),
    ParamDef('F14.23', 'Puissance min (kW)', 0, 100),
    ParamDef('F00.02', 'Mode commande', 0, 3),
  ];

  @override
  void initState() {
    super.initState();
    _loadSeuils();
  }

  Future<void> _loadSeuils() async {
    final data = await firebase.getSeuils();
    setState(() { seuils = data; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Parametres du variateur')),
      body: ListView.builder(
        itemCount: parametres.length,
        itemBuilder: (ctx, index) {
          final p = parametres[index];
          int currentValue = 0;
          if (p.code == 'F14.11') currentValue = (seuils['veille'] ?? 0).toInt();
          else if (p.code == 'F14.12') currentValue = (seuils['reveil'] ?? 0).toInt();
          else if (p.code == 'F14.14') currentValue = (seuils['basse_freq'] ?? 0).toInt();
          else if (p.code == 'F14.17') currentValue = (seuils['marche_sec'] ?? 0).toInt();
          else if (p.code == 'F14.20') currentValue = (seuils['surintensite'] ?? 0).toInt();
          else if (p.code == 'F14.23') currentValue = (seuils['puiss_min'] ?? 0).toInt();

          return ListTile(
            title: Text('${p.code} - ${p.label}'),
            subtitle: Text('Valeur actuelle : $currentValue ${p.unite}'),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final newValue = await showDialog<int>(
                context: context,
                builder: (ctx) {
                  int temp = currentValue;
                  return StatefulBuilder(builder: (ctx, setState) {
                    return AlertDialog(
                      title: Text(p.label),
                      content: Column(mainAxisSize: MainAxisSize.min, children: [
                        Slider(
                          min: p.min.toDouble(), max: p.max.toDouble(),
                          divisions: (p.max - p.min).toInt(),
                          value: temp.toDouble(),
                          onChanged: (val) => setState(() => temp = val.toInt()),
                        ),
                        Text('$temp ${p.unite}'),
                      ]),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, temp), child: const Text('Appliquer')),
                      ],
                    );
                  });
                },
              );
              if (newValue != null && newValue != currentValue) {
                await firebase.setParametre(p.code, newValue);
                _loadSeuils();
              }
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () async {
            await firebase.resetVariateur();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset du variateur demande')),
              );
            }
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reset variateur (parametres usine)'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
      ),
    );
  }
}

class ParamDef {
  final String code;
  final String label;
  final int min;
  final int max;
  String get unite {
    if (code == 'F14.11' || code == 'F14.12') return 'V';
    if (code == 'F14.14') return 'Hz';
    if (code == 'F14.17' || code == 'F14.20') return 'A';
    if (code == 'F14.23') return 'kW';
    return '';
  }
  ParamDef(this.code, this.label, this.min, this.max);
}
