import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gps_data.dart';
import '../services/pompe_service.dart';

class LocalisationScreen extends StatelessWidget {
  const LocalisationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localisation de la pompe')),
      body: StreamBuilder<GPSData>(
        stream: context.read<PompeService>().gpsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final gps = snapshot.data!;
          if (!gps.valide) {
            return const Center(child: Text('Position GPS non disponible'));
          }
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(gps.latitude, gps.longitude),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.smartpumpmonitor',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(gps.latitude, gps.longitude),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_pin,
                              color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.sim_card),
                          title: const Text('Opérateur SIM'),
                          subtitle: Text(gps.operateur),
                        ),
                        ListTile(
                          leading: const Icon(Icons.satellite),
                          title: const Text('Satellites'),
                          subtitle: Text('${gps.satellites ?? 0}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Coordonnées GPS'),
                          subtitle: Text(
                              '${gps.latitude.toStringAsFixed(6)}°, ${gps.longitude.toStringAsFixed(6)}°'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(gps.googleMaps);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Impossible d\'ouvrir Google Maps')),
                              );
                            }
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Ouvrir dans Google Maps'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
