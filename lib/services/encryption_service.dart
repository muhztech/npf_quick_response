import 'dart:io';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final _key = Key.fromUtf8('16CHARSECRETKEY!'); // demo key
  static final _iv = IV.fromLength(16);

  static Future<File> encryptFile(File inputFile) async {
    final bytes = await inputFile.readAsBytes();
    final encrypter = Encrypter(AES(_key));

    final encrypted = encrypter.encryptBytes(bytes, iv: _iv);

    final encryptedFile =
        File('${inputFile.path}.enc');

    await encryptedFile.writeAsBytes(encrypted.bytes);
    await inputFile.delete();

    return encryptedFile;
  }
}
