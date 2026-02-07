import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/encryption_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isMasterPasswordSet = false;
  bool _isLoading = true;
  Uint8List? _derivedKey;

  bool get isAuthenticated => _isAuthenticated;
  bool get isMasterPasswordSet => _isMasterPasswordSet;
  bool get isLoading => _isLoading;
  Uint8List? get derivedKey => _derivedKey;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _isMasterPasswordSet = await _authService.isMasterPasswordSet();
    } catch (e) {
      debugPrint('AuthProvider _init error: $e');
      _isMasterPasswordSet = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> setupMasterPassword(String password) async {
    try {
      final salt = await _authService.setupMasterPassword(password);
      _derivedKey = await EncryptionService.deriveKey(password, salt);
      _isMasterPasswordSet = true;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('setupMasterPassword error: $e');
      return false;
    }
  }

  Future<bool> unlock(String password) async {
    try {
      final salt = await _authService.verifyMasterPassword(password);
      if (salt == null) return false;

      _derivedKey = await EncryptionService.deriveKey(password, salt);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void lock() {
    _isAuthenticated = false;
    _derivedKey = null;
    notifyListeners();
  }

  /// Changes master password and re-encrypts all entries.
  /// Returns the new derived key on success.
  Future<Uint8List?> changeMasterPassword(String currentPassword, String newPassword) async {
    // Verify current password
    final currentSalt = await _authService.verifyMasterPassword(currentPassword);
    if (currentSalt == null) return null;

    // Change password
    final newSalt = await _authService.changeMasterPassword(newPassword);
    final newKey = await EncryptionService.deriveKey(newPassword, newSalt);

    _derivedKey = newKey;
    notifyListeners();
    return newKey;
  }
}
