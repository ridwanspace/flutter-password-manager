import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  /// Derives a 256-bit key from a master password using PBKDF2 with SHA-256.
  /// This is async to avoid blocking the UI thread on web.
  static Future<Uint8List> deriveKey(String password, String saltBase64, {int iterations = 100000}) async {
    final salt = base64.decode(saltBase64);
    final key = await _pbkdf2(utf8.encode(password), salt, iterations, 32);
    return key;
  }

  /// Generates a random salt encoded as base64.
  static String generateSalt([int length = 32]) {
    final random = Random.secure();
    final salt = Uint8List(length);
    for (int i = 0; i < length; i++) {
      salt[i] = random.nextInt(256);
    }
    return base64.encode(salt);
  }

  /// Encrypts plaintext using AES-256-CBC with a random IV.
  /// Returns `iv_base64:ciphertext_base64`.
  static String encryptText(String plaintext, Uint8List keyBytes) {
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a string in the format `iv_base64:ciphertext_base64`.
  static String decryptText(String encryptedText, Uint8List keyBytes) {
    final parts = encryptedText.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid encrypted text format');
    }
    final iv = encrypt.IV.fromBase64(parts[0]);
    final key = encrypt.Key(keyBytes);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    return encrypter.decrypt64(parts[1], iv: iv);
  }

  /// PBKDF2 implementation using HMAC-SHA256.
  /// Yields to the event loop every 5000 iterations to keep the UI responsive.
  static Future<Uint8List> _pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) async {
    final hmacSha256 = Hmac(sha256, password);
    final numBlocks = (keyLength + 31) ~/ 32;
    final result = BytesBuilder();

    for (int blockNum = 1; blockNum <= numBlocks; blockNum++) {
      final blockBytes = ByteData(4)..setUint32(0, blockNum);
      final saltWithBlock = Uint8List.fromList([
        ...salt,
        ...blockBytes.buffer.asUint8List(),
      ]);

      var u = hmacSha256.convert(saltWithBlock).bytes;
      var xorResult = Uint8List.fromList(u);

      for (int i = 1; i < iterations; i++) {
        u = hmacSha256.convert(u).bytes;
        for (int j = 0; j < xorResult.length; j++) {
          xorResult[j] ^= u[j];
        }
        // Yield every 5000 iterations to keep the browser responsive
        if (i % 5000 == 0) {
          await Future.delayed(Duration.zero);
        }
      }

      result.add(xorResult);
    }

    return Uint8List.fromList(result.toBytes().sublist(0, keyLength));
  }
}
