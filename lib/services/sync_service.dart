import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/evidence.dart';

class SyncService {
  static Future<void> syncEvidenceIfOnline() async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      return; // Offline
    }

    final box = Hive.box<Evidence>('evidenceBox');

    if (box.isEmpty) return;

    for (final evidence in box.values) {
      // TODO: upload to backend
      // await uploadEvidence(evidence);
    }

    // Future: clear box after confirmed upload
    // await box.clear();
  }
}
