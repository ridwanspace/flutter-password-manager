class MasterPassword {
  final int? id;
  final String passwordHash;
  final String salt;
  final DateTime createdAt;

  MasterPassword({
    this.id,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'password_hash': passwordHash,
      'salt': salt,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MasterPassword.fromMap(Map<String, dynamic> map) {
    return MasterPassword(
      id: map['id'] as int?,
      passwordHash: map['password_hash'] as String,
      salt: map['salt'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
