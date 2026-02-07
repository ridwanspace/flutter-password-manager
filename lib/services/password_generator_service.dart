import 'dart:math';

class PasswordGeneratorService {
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digits = '0123456789';
  static const String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  static String generate({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeDigits = true,
    bool includeSymbols = true,
  }) {
    String chars = '';
    final required = <String>[];

    if (includeLowercase) {
      chars += _lowercase;
      required.add(_lowercase);
    }
    if (includeUppercase) {
      chars += _uppercase;
      required.add(_uppercase);
    }
    if (includeDigits) {
      chars += _digits;
      required.add(_digits);
    }
    if (includeSymbols) {
      chars += _symbols;
      required.add(_symbols);
    }

    if (chars.isEmpty) {
      chars = _lowercase;
      required.add(_lowercase);
    }

    final random = Random.secure();
    final password = List<String>.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    );

    // Ensure at least one character from each required set
    for (int i = 0; i < required.length && i < length; i++) {
      final pos = random.nextInt(length);
      password[pos] = required[i][random.nextInt(required[i].length)];
    }

    return password.join();
  }

  static double calculateStrength(String password) {
    if (password.isEmpty) return 0;

    double score = 0;
    // Length contribution
    score += (password.length / 32).clamp(0, 0.3);

    // Character variety
    if (password.contains(RegExp(r'[a-z]'))) score += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.15;
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) score += 0.25;

    return score.clamp(0, 1);
  }

  static String strengthLabel(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.5) return 'Fair';
    if (strength < 0.7) return 'Good';
    if (strength < 0.9) return 'Strong';
    return 'Very Strong';
  }
}
