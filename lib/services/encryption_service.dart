import 'dart:io';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // 🔐 DEMO KEY (Replace later with secure key management)
  static final Key _key = Key.fromUtf8('16CHARSECRETKEY!');
  static final IV _iv = IV.fromLength(16);

  static final Encrypter _encrypter = Encrypter(
    AES(_key, mode: AESMode.cbc),
  );

  /* =========================
     PHASE 3 — FILE ENCRYPTION
     ========================= */

  static Future<File> encryptFile(File inputFile) async {
    final bytes = await inputFile.readAsBytes();

    final encrypted = _encrypter.encryptBytes(
      bytes,
      iv: _iv,
    );

    final encryptedFile = File('${inputFile.path}.enc');

    await encryptedFile.writeAsBytes(encrypted.bytes);

    // 🔥 Remove original plaintext file
    await inputFile.delete();

    return encryptedFile;
  }

  /* =========================
     PHASE 4 — FILE DECRYPTION
     (IN-MEMORY RENDERING)
     ========================= */

  static Future<File> decryptFile(File encryptedFile) async {
    final encryptedBytes = await encryptedFile.readAsBytes();

    final decryptedBytes = _encrypter.decryptBytes(
      Encrypted(encryptedBytes),
      iv: _iv,
    );

    // ⚠️ TEMP file (never stored in Hive)
    final tempFile = File(
      encryptedFile.path.replaceAll('.enc', '.tmp'),
    );

    await tempFile.writeAsBytes(decryptedBytes);

    return tempFile;
  }

  /* =========================
     PHASE 4 — PATH DECRYPTION
     (ONLY IF PATH IS ENCRYPTED)
     ========================= */

  static String encryptPath(String plainPath) {
    return _encrypter.encrypt(plainPath, iv: _iv).base64;
  }

  static String decryptPath(String encryptedPath) {
    return _encrypter.decrypt64(encryptedPath, iv: _iv);
  }
}
