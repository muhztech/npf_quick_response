import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';

class EvidenceEncryption {
  static final _key = Key.fromUtf8('16CHARSECRETKEY!'); // demo key

  /* =========================
     ENCRYPT + SAVE
     ========================= */
  static Future<Map<String, String>> encryptAndSave(
    File inputFile,
  ) async {
    final bytes = await inputFile.readAsBytes();

    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_key));

    final encrypted =
        encrypter.encryptBytes(bytes, iv: iv);

    final dir = await getApplicationDocumentsDirectory();
    final encryptedFile = File(
      '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.enc',
    );

    await encryptedFile.writeAsBytes(encrypted.bytes);

    return {
      'path': encryptedFile.path,
      'iv': iv.base64,
    };
  }

  /* =========================
     DECRYPT TO BYTES
     ========================= */
  static Future<Uint8List> decryptToBytes(
    String encryptedPath,
    String ivBase64,
  ) async {
    final encryptedFile = File(encryptedPath);
    final encryptedBytes =
        await encryptedFile.readAsBytes();

    final iv = IV.fromBase64(ivBase64);
    final encrypter = Encrypter(AES(_key));

    final decrypted = encrypter.decryptBytes(
      Encrypted(encryptedBytes),
      iv: iv,
    );

    return Uint8List.fromList(decrypted);
  }
}
