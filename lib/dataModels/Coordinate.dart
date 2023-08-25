class Coordinate {
  final double latitude;        // Horizontal - Ex : Equateur = 0°, Pôle Nord = 90°, Pôle Sud = -90°
  final double longitude;       // Vertical   - Ex : Méridien de Greenwich = 0°, Méridien de Paris = 2.35°, Méridien de New York = -74°

  Coordinate({required this.latitude, required this.longitude});
}