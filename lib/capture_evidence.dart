import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import 'models/evidence.dart';
import 'services/location_service.dart';
import 'security/evidence_encryption.dart';

class CaptureEvidencePage extends StatefulWidget {
  const CaptureEvidencePage({super.key});

  @override
  State<CaptureEvidencePage> createState() =>
      _CaptureEvidencePageState();
}

class _CaptureEvidencePageState
    extends State<CaptureEvidencePage> {
  final ImagePicker _picker = ImagePicker();

  String? _encryptedPath;
  String? _ivBase64; // 🔐 persisted IV
  Uint8List? _previewBytes;

  Position? _position;
  String? _timestamp;
  String? _locationName;

  bool _loadingLocation = false;
  bool _processingImage = false;

  /* =========================
     CAMERA CAPTURE
     ========================= */
  Future<void> _captureImage() async {
    if (_processingImage) return;
    _processingImage = true;

    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;

      final rawImage = File(picked.path);

      final result =
          await EvidenceEncryption.encryptAndSave(rawImage);

      final preview =
          await EvidenceEncryption.decryptToBytes(
        result['path']!,
        result['iv']!,
      );

      if (!mounted) return;

      setState(() {
        _encryptedPath = result['path'];
        _ivBase64 = result['iv'];
        _previewBytes = preview;
        _timestamp = _generateTimestamp();
      });

      await _fetchLocation();
    } catch (e, stack) {
      debugPrint('CAPTURE ERROR: $e');
      debugPrint(stack.toString());
      _showMessage('Failed to capture evidence');
    } finally {
      _processingImage = false;
    }
  }

  /* =========================
     GALLERY PICK
     ========================= */
  Future<void> _pickFromGallery() async {
    if (_processingImage) return;
    _processingImage = true;

    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final rawImage = File(picked.path);

      final result =
          await EvidenceEncryption.encryptAndSave(rawImage);

      final preview =
          await EvidenceEncryption.decryptToBytes(
        result['path']!,
        result['iv']!,
      );

      if (!mounted) return;

      setState(() {
        _encryptedPath = result['path'];
        _ivBase64 = result['iv'];
        _previewBytes = preview;
        _timestamp = _generateTimestamp();
      });

      await _fetchLocation();
    } catch (e, stack) {
      debugPrint('GALLERY ERROR: $e');
      debugPrint(stack.toString());
      _showMessage('Failed to load image');
    } finally {
      _processingImage = false;
    }
  }

  /* =========================
     LOCATION FETCH
     ========================= */
  Future<void> _fetchLocation() async {
    if (!mounted) return;
    setState(() => _loadingLocation = true);

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('Location services are disabled.');
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage('Location permission denied.');
          return;
        }
      }

      if (permission ==
          LocationPermission.deniedForever) {
        _showMessage(
          'Location permission permanently denied.',
        );
        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationName =
          await LocationService.resolveAddress(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _position = position;
        _locationName = locationName;
      });
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  /* =========================
     TIMESTAMP
     ========================= */
  String _generateTimestamp() {
    return DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.now());
  }

  /* =========================
     SNACKBAR
     ========================= */
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /* =========================
     SAVE TO HIVE
     ========================= */
  Future<void> _attachEvidence() async {
    if (_encryptedPath == null ||
        _ivBase64 == null ||
        _position == null) return;

    final evidence = Evidence(
      encryptedPath: _encryptedPath!,
      ivBase64: _ivBase64!, // 🔐 persisted IV
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      timestamp: DateTime.now(),
      locationName:
          _locationName ?? 'Unknown location',
    );

    final box = Hive.box<Evidence>('evidenceBox');
    await box.add(evidence);

    if (!mounted) return;
    Navigator.pop(context, evidence);
  }

  /* =========================
     UI
     ========================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Capture Evidence')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_previewBytes != null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: Image.memory(
                  _previewBytes!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            if (_timestamp != null)
              _infoTile(
                Icons.access_time,
                'Timestamp',
                _timestamp!,
              ),

            if (_loadingLocation)
              const Padding(
                padding: EdgeInsets.all(12),
                child:
                    CircularProgressIndicator(),
              ),

            if (_locationName != null)
              _infoTile(
                Icons.location_on,
                'Location',
                _locationName!,
              ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon:
                        const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed:
                        _processingImage
                            ? null
                            : _captureImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon:
                        const Icon(Icons.photo),
                    label:
                        const Text('Gallery'),
                    onPressed:
                        _processingImage
                            ? null
                            : _pickFromGallery,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon:
                    const Icon(Icons.attach_file),
                label:
                    const Text('Attach Evidence'),
                onPressed:
                    (_encryptedPath != null &&
                            _ivBase64 != null &&
                            _position != null)
                        ? _attachEvidence
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
