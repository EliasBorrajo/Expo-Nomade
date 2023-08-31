class Coordinate {
  final String latitude;        // Horizontal - Ex : Equateur = 0°, Pôle Nord = 90°, Pôle Sud = -90°
  final String longitude;       // Vertical   - Ex : Méridien de Greenwich = 0°, Méridien de Paris = 2.35°, Méridien de New York = -74°

  Coordinate({required this.latitude, required this.longitude});

  factory Coordinate.fromMap(Map<String, dynamic> map) {
    return Coordinate(
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
    );
  }
}