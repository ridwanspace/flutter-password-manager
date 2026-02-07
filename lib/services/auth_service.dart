import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/master_password.dart';
import '../services/database_helper.dart';
import '../services/encryption_service.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Hashes the master password with a salt using SHA-256.
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Checks if a master password has been set up.
  Future<bool> isMasterPasswordSet() async {
    final mp = await _dbHelper.getMasterPassword();
    return mp != null;
  }

  /// Sets up the initial master password.
  /// Returns the salt for key derivation.
  Future<String> setupMasterPassword(String password) async {
    final salt = EncryptionService.generateSalt();
    final hash = hashPassword(password, salt);

    final mp = MasterPassword(
      passwordHash: hash,
      salt: salt,
      createdAt: DateTime.now(),
    );

    await _dbHelper.insertMasterPassword(mp);
    return salt;
  }

  /// Verifies the master password.
  /// Returns the salt if valid, null otherwise.
  Future<String?> verifyMasterPassword(String password) async {
    final mp = await _dbHelper.getMasterPassword();
    if (mp == null) return null;

    final hash = hashPassword(password, mp.salt);
    if (hash == mp.passwordHash) {
      return mp.salt;
    }
    return null;
  }

  /// Changes the master password. Returns the new salt.
  Future<String> changeMasterPassword(String newPassword) async {
    final mp = await _dbHelper.getMasterPassword();
    final newSalt = EncryptionService.generateSalt();
    final newHash = hashPassword(newPassword, newSalt);

    final updatedMp = MasterPassword(
      id: mp?.id,
      passwordHash: newHash,
      salt: newSalt,
      createdAt: mp?.createdAt ?? DateTime.now(),
    );

    if (mp != null) {
      await _dbHelper.updateMasterPassword(updatedMp);
    } else {
      await _dbHelper.insertMasterPassword(updatedMp);
    }

    return newSalt;
  }
}
