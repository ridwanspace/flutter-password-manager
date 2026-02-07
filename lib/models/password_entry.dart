class PasswordEntry {
  final int? id;
  final String title;
  final String? username;
  final String encryptedPassword;
  final String? encryptedNotes;
  final String? url;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PasswordEntry({
    this.id,
    required this.title,
    this.username,
    required this.encryptedPassword,
    this.encryptedNotes,
    this.url,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'encrypted_password': encryptedPassword,
      'encrypted_notes': encryptedNotes,
      'url': url,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'] as int?,
      title: map['title'] as String,
      username: map['username'] as String?,
      encryptedPassword: map['encrypted_password'] as String,
      encryptedNotes: map['encrypted_notes'] as String?,
      url: map['url'] as String?,
      categoryId: map['category_id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  PasswordEntry copyWith({
    int? id,
    String? title,
    String? username,
    String? encryptedPassword,
    String? encryptedNotes,
    String? url,
    int? categoryId,
    bool clearCategory = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      encryptedNotes: encryptedNotes ?? this.encryptedNotes,
      url: url ?? this.url,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
