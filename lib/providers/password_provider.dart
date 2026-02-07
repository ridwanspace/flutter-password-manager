import 'package:flutter/foundation.dart';
import '../models/password_entry.dart';
import '../services/database_helper.dart';
import '../services/encryption_service.dart';

class PasswordProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<PasswordEntry> _entries = [];
  List<PasswordEntry> _filteredEntries = [];
  String _searchQuery = '';
  int? _selectedCategoryId;
  bool _isLoading = false;

  List<PasswordEntry> get entries => _filteredEntries;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    _entries = await _dbHelper.getPasswordEntries();
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredEntries = _entries.where((entry) {
      // Category filter
      if (_selectedCategoryId != null && entry.categoryId != _selectedCategoryId) {
        return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return entry.title.toLowerCase().contains(query) ||
            (entry.username?.toLowerCase().contains(query) ?? false) ||
            (entry.url?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();
  }

  Future<bool> addEntry({
    required String title,
    String? username,
    required String password,
    String? notes,
    String? url,
    int? categoryId,
    required Uint8List encryptionKey,
  }) async {
    try {
      final encryptedPassword = EncryptionService.encryptText(password, encryptionKey);
      final encryptedNotes = notes != null && notes.isNotEmpty
          ? EncryptionService.encryptText(notes, encryptionKey)
          : null;
      final now = DateTime.now();

      final entry = PasswordEntry(
        title: title,
        username: username,
        encryptedPassword: encryptedPassword,
        encryptedNotes: encryptedNotes,
        url: url,
        categoryId: categoryId,
        createdAt: now,
        updatedAt: now,
      );

      await _dbHelper.insertPasswordEntry(entry);
      await loadEntries();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateEntry({
    required int id,
    required String title,
    String? username,
    required String password,
    String? notes,
    String? url,
    int? categoryId,
    bool clearCategory = false,
    required Uint8List encryptionKey,
    required DateTime createdAt,
  }) async {
    try {
      final encryptedPassword = EncryptionService.encryptText(password, encryptionKey);
      final encryptedNotes = notes != null && notes.isNotEmpty
          ? EncryptionService.encryptText(notes, encryptionKey)
          : null;

      final entry = PasswordEntry(
        id: id,
        title: title,
        username: username,
        encryptedPassword: encryptedPassword,
        encryptedNotes: encryptedNotes,
        url: url,
        categoryId: clearCategory ? null : categoryId,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

      await _dbHelper.updatePasswordEntry(entry);
      await loadEntries();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEntry(int id) async {
    try {
      await _dbHelper.deletePasswordEntry(id);
      await loadEntries();
      return true;
    } catch (e) {
      return false;
    }
  }

  String decryptPassword(String encryptedPassword, Uint8List key) {
    return EncryptionService.decryptText(encryptedPassword, key);
  }

  String? decryptNotes(String? encryptedNotes, Uint8List key) {
    if (encryptedNotes == null) return null;
    return EncryptionService.decryptText(encryptedNotes, key);
  }

  /// Re-encrypts all entries with a new key. Used when changing master password.
  Future<void> reEncryptAllEntries(Uint8List oldKey, Uint8List newKey) async {
    final allEntries = await _dbHelper.getPasswordEntries();

    for (final entry in allEntries) {
      final plainPassword = EncryptionService.decryptText(entry.encryptedPassword, oldKey);
      String? plainNotes;
      if (entry.encryptedNotes != null) {
        plainNotes = EncryptionService.decryptText(entry.encryptedNotes!, oldKey);
      }

      final newEncPassword = EncryptionService.encryptText(plainPassword, newKey);
      final newEncNotes = plainNotes != null
          ? EncryptionService.encryptText(plainNotes, newKey)
          : null;

      final updated = entry.copyWith(
        encryptedPassword: newEncPassword,
        encryptedNotes: newEncNotes,
        updatedAt: DateTime.now(),
      );
      await _dbHelper.updatePasswordEntry(updated);
    }

    await loadEntries();
  }
}
