class AppConstants {
  static const String dbName = 'password_manager.db';
  static const int dbVersion = 1;

  static const String tableMasterPassword = 'master_password';
  static const String tableCategories = 'categories';
  static const String tablePasswordEntries = 'password_entries';

  static const int pbkdf2Iterations = 100000;
  static const int keyLength = 32; // 256 bits
  static const int saltLength = 32;

  static const int clipboardClearSeconds = 30;
  static const int defaultPasswordLength = 16;

  static const List<Map<String, String>> defaultCategories = [
    {'name': 'Social Media', 'icon': 'people'},
    {'name': 'Email', 'icon': 'email'},
    {'name': 'Finance', 'icon': 'account_balance'},
    {'name': 'Shopping', 'icon': 'shopping_cart'},
    {'name': 'Work', 'icon': 'work'},
    {'name': 'Entertainment', 'icon': 'movie'},
    {'name': 'Other', 'icon': 'folder'},
  ];
}
