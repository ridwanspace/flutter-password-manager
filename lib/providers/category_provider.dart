import 'package:flutter/foundation.dart';
import '../models/category.dart' as model;
import '../services/database_helper.dart';

class CategoryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<model.Category> _categories = [];
  bool _isLoading = false;

  List<model.Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _dbHelper.getCategories();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCategory(String name, String icon) async {
    try {
      final category = model.Category(name: name, icon: icon);
      await _dbHelper.insertCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _dbHelper.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  model.Category? getCategoryById(int? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
