import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';

class GraphiquesScreen extends StatefulWidget {
  const GraphiquesScreen({super.key});

  @override
  State<GraphiquesScreen> createState() => _GraphiquesScreenState();
}

class _GraphiquesScreenState extends State<GraphiquesScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _data = {};
  bool _loading = false;
  final firebase = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final data = await firebase.getHistoriqueJour(dateStr);
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  List<FlSpot> _getSpots(String key) {
    List<FlSpot> spots = [];
    _data.forEach((heure, values) {
      int h = int.parse(heure);
      double val = (values[key] ?? 0).toDouble();
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Puissance (kW)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getSpots('puissance_sortie'),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}h');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()} kW');
                                },
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
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Courant (A)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getSpots('courant_sortie'),
                              isCurved: true,
                              color: Colors.red,
                              barWidth: 3,
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}