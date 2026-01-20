import 'package:hive/hive.dart';

part 'evidence.g.dart';

@HiveType(typeId: 0)
class Evidence {
  @HiveField(0)
  final String encryptedPath;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String locationName;

  // 🔐 Persisted IV (Base64)
  @HiveField(5)
  final String ivBase64;

  Evidence({
    required this.encryptedPath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.ivBase64,
    this.locationName = 'Unknown location',
  });

  String get formattedTime {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
