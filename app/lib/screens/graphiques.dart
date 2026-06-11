import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/pompe_service.dart';

class GraphiquesScreen extends StatefulWidget {
  const GraphiquesScreen({super.key});

  @override
  State<GraphiquesScreen> createState() => _GraphiquesScreenState();
}

class _GraphiquesScreenState extends State<GraphiquesScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _data = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final data =
        await context.read<PompeService>().getHistoriqueJour(dateStr);
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  List<FlSpot> _getSpots(String key) {
    final spots = <FlSpot>[];
    _data.forEach((heure, values) {
      final h = int.parse(heure);
      final val = (values[key] ?? 0).toDouble();
      spots.add(FlSpot(h.toDouble(), val));
    });
    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique de consommation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
                _loadData();
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? const Center(child: Text('Aucune donnée pour ce jour'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _graphiqueCard(
                        titre: 'Puissance (kW)',
                        spots: _getSpots('puissance_sortie'),
                        couleur: Colors.blue,
                        unite: 'kW',
                      ),
                      const SizedBox(height: 16),
                      _graphiqueCard(
                        titre: 'Courant (A)',
                        spots: _getSpots('courant_sortie'),
                        couleur: Colors.red,
                        unite: 'A',
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _graphiqueCard({
    required String titre,
    required List<FlSpot> spots,
    required Color couleur,
    required String unite,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(titre, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: couleur,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()}h'),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()} $unite'),
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
