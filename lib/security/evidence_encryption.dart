import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class EvidenceEncryption {
  // 🔑 Static key (Phase 1)
  // Later: derive per-device
  static final _key = Key.fromUtf8(
    '32_characters_secure_key_here!'
  );
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  /// Encrypt image file → returns encrypted file path
  static Future<String> encryptAndSave(File image) async {
    final bytes = await image.readAsBytes();
    final encrypted = _encrypter.encryptBytes(bytes, iv: _iv);

    final dir = await getApplicationDocumentsDirectory();
    final encryptedPath = p.join(
      dir.path,
      'evidence_${DateTime.now().millisecondsSinceEpoch}.enc',
    );

    final encryptedFile = File(encryptedPath);
    await encryptedFile.writeAsBytes(encrypted.bytes);

    return encryptedPath;
  }

  /// Decrypt encrypted file → Uint8List for preview
  static Future<Uint8List> decryptToBytes(String encryptedPath) async {
    final encryptedBytes = await File(encryptedPath).readAsBytes();
    final encrypted = Encrypted(encryptedBytes);
    final decrypted = _encrypter.decryptBytes(encrypted, iv: _iv);
    return Uint8List.fromList(decrypted);
  }
}
