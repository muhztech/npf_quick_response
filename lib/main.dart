import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/evidence.dart';
import 'emergency_sos.dart';
import 'report_incident.dart';
import 'capture_evidence.dart';
import 'services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /* =========================
     HIVE INITIALIZATION
     ========================= */
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(EvidenceAdapter());
  }

  await Hive.openBox<Evidence>('evidenceBox');

  // Sync when app starts
  SyncService.syncEvidenceIfOnline();

  runApp(const NpfQuickResponseApp());
}

class NpfQuickResponseApp extends StatelessWidget {
  const NpfQuickResponseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NPF Quick Response',
      debugShowCheckedModeBanner: false,

      /* =========================
         GLOBAL APP THEME
         ========================= */
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B3C5D), // Police Blue
          primary: const Color(0xFF0B3C5D),
          secondary: const Color(0xFFF4B41A), // Gold
          error: const Color(0xFFC62828),
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B3C5D),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B3C5D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // ✅ FIXED FOR MATERIAL 3
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFF4B41A),
          foregroundColor: Colors.black,
        ),
      ),

      home: const DashboardPage(),
    );
  }
}

/* =========================
   DASHBOARD (HOME SCREEN)
   ========================= */
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NPF Quick Response'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            DashboardCard(
              icon: Icons.report,
              label: 'Report Incident',
            ),
            DashboardCard(
              icon: Icons.camera_alt,
              label: 'Capture Evidence',
            ),
            DashboardCard(
              icon: Icons.warning_amber_rounded,
              label: 'Emergency SOS',
            ),
            DashboardCard(
              icon: Icons.info_outline,
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   DASHBOARD CARD
   ========================= */
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.label,
  });

  bool get isEmergency => label == 'Emergency SOS';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isEmergency
          ? const Color(0xFFC62828).withOpacity(0.1)
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: isEmergency ? 6 : 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: isEmergency
            ? Colors.red.withOpacity(0.3)
            : Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.2),
        onTap: () {
          switch (label) {
            case 'Emergency SOS':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmergencySOSPage(),
                ),
              );
              break;

            case 'Report Incident':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportIncidentPage(),
                ),
              );
              break;

            case 'Capture Evidence':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CaptureEvidencePage(),
                ),
              );
              break;

            case 'About':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutPage(),
                ),
              );
              break;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 52,
                color: isEmergency
                    ? const Color(0xFFC62828)
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEmergency
                      ? const Color(0xFFC62828)
                      : null,
                ),
              ),
              if (isEmergency) ...[
                const SizedBox(height: 6),
                const Text(
                  'Tap for immediate help',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
   ABOUT PAGE
   ========================= */
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'NPF Quick Response',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This application enables citizens to report incidents, '
              'capture evidence, and trigger emergency SOS alerts '
              'for rapid police response.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 12),
            Text(
              'Developed by:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'muhztech',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3C5D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
