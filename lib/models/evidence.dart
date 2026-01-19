import 'package:hive/hive.dart';

part 'evidence.g.dart';

@HiveType(typeId: 0)
class Evidence {
  @HiveField(0)
  final String imagePath;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final DateTime timestamp;

  // ✅ Human-readable location (e.g. Lafia, Nasarawa)
  @HiveField(4)
  final String locationName;

  Evidence({
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.locationName = 'Unknown location', // ✅ SAFE DEFAULT
  });

  /* =========================
     FORMATTED TIME (UI)
     ========================= */
  String get formattedTime {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /* =========================
     MAP CONVERSION
     ========================= */
  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'locationName': locationName,
    };
  }

  factory Evidence.fromMap(Map<String, dynamic> map) {
    return Evidence(
      imagePath: map['imagePath'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
      locationName: map['locationName'] ?? 'Unknown location',
    );
  }
}
