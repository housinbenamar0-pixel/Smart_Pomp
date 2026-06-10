class GPSData {
  final double latitude;
  final double longitude;
  final bool valide;
  final String operateur;
  final String googleMaps;
  final double? altitude;
  final double? vitesse;
  final int? satellites;
  final String timestamp;

  GPSData({
    required this.latitude,
    required this.longitude,
    required this.valide,
    required this.operateur,
    required this.googleMaps,
    this.altitude,
    this.vitesse,
    this.satellites,
    required this.timestamp,
  });

  factory GPSData.fromJson(Map<String, dynamic> json) {
    return GPSData(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      valide: json['valide'] ?? false,
      operateur: json['operateur'] ?? 'Inconnu',
      googleMaps: json['google_maps'] ?? '',
      altitude: json['altitude']?.toDouble(),
      vitesse: json['vitesse']?.toDouble(),
      satellites: json['satellites'],
      timestamp: json['timestamp'] ?? '',
    );
  }
}