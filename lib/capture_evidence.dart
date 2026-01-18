import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import 'models/evidence.dart';

class CaptureEvidencePage extends StatefulWidget {
  const CaptureEvidencePage({super.key});

  @override
  State<CaptureEvidencePage> createState() => _CaptureEvidencePageState();
}

class _CaptureEvidencePageState extends State<CaptureEvidencePage> {
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  Position? _position;
  String? _timestamp;
  bool _loadingLocation = false;

  /* =========================
     PICK IMAGE FROM CAMERA
     ========================= */
  Future<void> _captureImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _timestamp = _generateTimestamp();
      });
      await _fetchLocation();
    }
  }

  /* =========================
     PICK IMAGE FROM GALLERY
     ========================= */
  Future<void> _pickFromGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _timestamp = _generateTimestamp();
      });
      await _fetchLocation();
    }
  }

  /* =========================
     GET GPS LOCATION
     ========================= */
  Future<void> _fetchLocation() async {
    setState(() => _loadingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Location services are disabled.');
      setState(() => _loadingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage('Location permission denied.');
        setState(() => _loadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage(
        'Location permission permanently denied. Enable in settings.',
      );
      setState(() => _loadingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _position = position;
      _loadingLocation = false;
    });
  }

  /* =========================
     TIMESTAMP GENERATOR
     ========================= */
  String _generateTimestamp() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  /* =========================
     SNACKBAR HELPER
     ========================= */
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /* =========================
     ATTACH + SAVE TO HIVE
     ========================= */
  Future<void> _attachEvidence() async {
    if (_imageFile == null || _position == null) return;

    final evidence = Evidence(
      imagePath: _imageFile!.path,
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      timestamp: DateTime.now(),
    );

    // 🔐 SAVE OFFLINE (Hive)
    final box = Hive.box<Evidence>('evidenceBox');
    await box.add(evidence);

    Navigator.pop(context, evidence);
  }

  /* =========================
     UI
     ========================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Evidence')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _imageFile!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            if (_timestamp != null)
              _infoTile(Icons.access_time, 'Timestamp', _timestamp!),

            if (_loadingLocation)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),

            if (_position != null)
              _infoTile(
                Icons.location_on,
                'Location',
                'Lat: ${_position!.latitude}, '
                'Lng: ${_position!.longitude}',
              ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: _captureImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text('Gallery'),
                    onPressed: _pickFromGallery,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach Evidence'),
                onPressed:
                    (_imageFile != null && _position != null)
                        ? _attachEvidence
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* =========================
     INFO TILE
     ========================= */
  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
