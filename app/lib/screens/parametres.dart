import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pompe_service.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});
  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  Map<String, dynamic> seuils = {};
  bool loading = true;

  final List<_ParamDef> parametres = const [
    _ParamDef('F14.11', 'Seuil veille (V)', 0, 1000),
    _ParamDef('F14.12', 'Seuil reveil (V)', 0, 1000),
    _ParamDef('F14.14', 'Frequence min (Hz)', 0, 300),
    _ParamDef('F14.17', 'Courant marche a sec (A)', 0, 100),
    _ParamDef('F14.20', 'Seuil surintensite (A)', 0, 100),
    _ParamDef('F14.23', 'Puissance min (kW)', 0, 100),
    _ParamDef('F00.02', 'Mode commande', 0, 3),
  ];

  @override
  void initState() {
    super.initState();
    _loadSeuils();
  }

  Future<void> _loadSeuils() async {
    final data = await context.read<PompeService>().getSeuils();
    setState(() {
      seuils = data;
      loading = false;
    });
  }

  int _valeurActuelle(_ParamDef p) {
    switch (p.code) {
      case 'F14.11': return (seuils['veille']      ?? 0).toInt();
      case 'F14.12': return (seuils['reveil']      ?? 0).toInt();
      case 'F14.14': return (seuils['basse_freq']  ?? 0).toInt();
      case 'F14.17': return (seuils['marche_sec']  ?? 0).toInt();
      case 'F14.20': return (seuils['surintensite']?? 0).toInt();
      case 'F14.23': return (seuils['puiss_min']   ?? 0).toInt();
      default:       return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Parametres du variateur')),
      body: ListView.builder(
        itemCount: parametres.length,
        itemBuilder: (ctx, index) {
          final p = parametres[index];
          final currentValue = _valeurActuelle(p);
          return ListTile(
            title: Text('${p.code} - ${p.label}'),
            subtitle: Text('Valeur actuelle : $currentValue ${p.unite}'),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final pompe = context.read<PompeService>();
              final newValue = await showDialog<int>(
                context: context,
                builder: (ctx) {
                  int temp = currentValue;
                  return StatefulBuilder(builder: (ctx, setDlgState) {
                    return AlertDialog(
                      title: Text(p.label),
                      content: Column(mainAxisSize: MainAxisSize.min, children: [
                        Slider(
                          min: p.min.toDouble(),
                          max: p.max.toDouble(),
                          divisions: p.max - p.min,
                          value: temp.toDouble(),
                          onChanged: (val) =>
                              setDlgState(() => temp = val.toInt()),
                        ),
                        Text('$temp ${p.unite}'),
                      ]),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, temp),
                          child: const Text('Appliquer'),
                        ),
                      ],
                    );
                  });
                },
              );
              if (newValue != null && newValue != currentValue) {
                await pompe.setParametre(p.code, newValue);
                if (mounted) _loadSeuils();
              }
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () async {
            await context.read<PompeService>().resetVariateur();
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

class _ParamDef {
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

  const _ParamDef(this.code, this.label, this.min, this.max);
}
